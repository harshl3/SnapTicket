import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { useUser } from '../context/UserContext';
import { getUserBookings } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';

const BookingSuccess = () => {
  const { bookingReference } = useParams();
  const { currentUser } = useUser();
  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchBookingDetails = async () => {
      if (!currentUser) {
        setLoading(false);
        return;
      }
      try {
        setLoading(true);
        const data = await getUserBookings(currentUser._id);
        if (data.success && data.bookings) {
          const found = data.bookings.find(b => b.bookingReference === bookingReference);
          if (found) {
            setBooking(found);
          } else {
            setError('Booking not found in user records.');
          }
        } else {
          setError('Failed to fetch bookings.');
        }
      } catch (err) {
        console.error(err);
        setError('Error retrieving booking receipt details.');
      } finally {
        setLoading(false);
      }
    };

    fetchBookingDetails();
  }, [bookingReference, currentUser]);

  if (loading) {
    return <LoadingSpinner message="Generating confirmation receipt..." />;
  }

  if (!currentUser) {
    return (
      <div className="booking-success-page text-center py-5">
        <ErrorMessage message="Please select a user to view this booking success page." />
        <div className="mt-4">
          <Link to="/" className="btn btn-primary">Browse Events</Link>
        </div>
      </div>
    );
  }

  if (error || !booking) {
    return (
      <div className="booking-success-page text-center py-5">
        <ErrorMessage message={error || 'Unable to retrieve booking details.'} />
        <div className="mt-4">
          <Link to="/" className="btn btn-primary">Back to Home</Link>
        </div>
      </div>
    );
  }

  return (
    <div className="booking-success-page">
      <div className="success-container">
        <div className="success-header">
          <div className="success-checkmark-circle">✓</div>
          <h2 className="success-title">Booking Confirmed!</h2>
          <p className="success-subtitle">Your seats have been successfully reserved.</p>
        </div>

        <div className="receipt-card">
          <div className="receipt-header">
            <span className="receipt-ref-label">Booking Reference</span>
            <span className="receipt-ref-value">{booking.bookingReference}</span>
          </div>

          <div className="receipt-body">
            <div className="receipt-section">
              <h3 className="receipt-event-name">{booking.event.name}</h3>
              <p className="receipt-venue">📍 {booking.event.venue}</p>
            </div>

            <div className="receipt-grid">
              <div className="receipt-grid-item">
                <span className="grid-label">Date</span>
                <span className="grid-value">{booking.event.date}</span>
              </div>
              <div className="receipt-grid-item">
                <span className="grid-label">Time</span>
                <span className="grid-value">{booking.event.time || 'N/A'}</span>
              </div>
              <div className="receipt-grid-item">
                <span className="grid-label">Tickets</span>
                <span className="grid-value">{booking.quantity}</span>
              </div>
              <div className="receipt-grid-item">
                <span className="grid-label">Total Amount</span>
                <span className="grid-value highlight-value">₹{booking.totalAmount}</span>
              </div>
            </div>

            <div className="receipt-footer">
              <span className="status-label">Status</span>
              <span className={`status-badge ${booking.bookingStatus.toLowerCase()}`}>
                {booking.bookingStatus}
              </span>
            </div>
          </div>
        </div>

        <div className="success-actions">
          <Link to="/my-bookings" className="btn btn-primary actions-btn">
            View My Bookings
          </Link>
          <Link to="/" className="btn btn-secondary actions-btn">
            Browse More Events
          </Link>
        </div>
      </div>
    </div>
  );
};

export default BookingSuccess;
