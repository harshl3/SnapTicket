import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useUser } from '../context/UserContext';
import { getUserBookings, cancelBooking as apiCancelBooking } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';

const MyBookings = () => {
  const { currentUser } = useUser();
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [cancelLoadingId, setCancelLoadingId] = useState(null);

  const fetchBookings = async () => {
    if (!currentUser) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      const data = await getUserBookings(currentUser._id);
      if (data.success) {
        setBookings(data.bookings);
      } else {
        setError(data.message || 'Failed to fetch bookings');
      }
    } catch (err) {
      console.error(err);
      setError('Could not retrieve bookings from the server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBookings();
  }, [currentUser]);

  const handleCancelBooking = async (bookingId, bookingRef) => {
    const confirmCancel = window.confirm(
      `Are you sure you want to cancel booking ${bookingRef}? This will release your reserved seats.`
    );
    
    if (!confirmCancel) return;

    try {
      setCancelLoadingId(bookingId);
      const data = await apiCancelBooking(bookingId);
      if (data.success) {
        alert(`Booking ${bookingRef} cancelled successfully.`);
        fetchBookings();
      } else {
        alert(data.message || 'Cancellation failed.');
      }
    } catch (err) {
      console.error(err);
      const serverMsg = err.response?.data?.message || 'Server error. Failed to cancel booking.';
      alert(serverMsg);
    } finally {
      setCancelLoadingId(null);
    }
  };

  if (!currentUser) {
    return (
      <div className="my-bookings-page-unauthenticated">
        <div className="unauth-container">
          <div className="unauth-icon">🔒</div>
          <h2 className="unauth-title">View Bookings</h2>
          <p className="unauth-text">Please select a mock user from the dropdown in the navigation bar to view your ticket bookings.</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return <LoadingSpinner message="Loading your tickets..." />;
  }

  if (error) {
    return (
      <div className="container py-5">
        <ErrorMessage message={error} onRetry={fetchBookings} />
      </div>
    );
  }

  return (
    <div className="my-bookings-page">
      <div className="page-header">
        <h2 className="page-title">My Bookings</h2>
        <p className="page-subtitle">Manage and track your active and cancelled reservations.</p>
      </div>

      {bookings.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">🎟️</div>
          <h3 className="empty-state-title">No Bookings Yet</h3>
          <p className="empty-state-text">You haven't booked tickets for any events. Discover upcoming events and reserve your seats now.</p>
          <Link to="/" className="btn btn-primary mt-4">Explore Events</Link>
        </div>
      ) : (
        <div className="bookings-list">
          {bookings.map((booking) => {
            const isConfirmed = booking.bookingStatus === 'CONFIRMED';
            const bookingDate = new Date(booking.createdAt).toLocaleDateString(undefined, {
              year: 'numeric',
              month: 'long',
              day: 'numeric'
            });

            return (
              <div key={booking._id} className="booking-receipt-card">
                <div className="receipt-card-top">
                  <div className="receipt-event-info">
                    <span className="receipt-card-category">{booking.event.category}</span>
                    <h3 className="receipt-card-title">{booking.event.name}</h3>
                    <div className="receipt-card-meta">
                      <span>📅 {booking.event.date}</span>
                      <span>🕒 {booking.event.time || 'N/A'}</span>
                      <span>📍 {booking.event.venue}</span>
                    </div>
                  </div>
                  <div className="receipt-status-section">
                    <span className={`status-badge ${booking.bookingStatus.toLowerCase()}`}>
                      {booking.bookingStatus}
                    </span>
                  </div>
                </div>

                <hr className="receipt-card-divider" />

                <div className="receipt-card-bottom">
                  <div className="receipt-metrics">
                    <div className="metric-item">
                      <span className="metric-label">Reference</span>
                      <span className="metric-value font-mono">{booking.bookingReference}</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Tickets</span>
                      <span className="metric-value">{booking.quantity}</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Total Paid</span>
                      <span className="metric-value price-value">₹{booking.totalAmount}</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Booked On</span>
                      <span className="metric-value date-value">{bookingDate}</span>
                    </div>
                  </div>

                  {isConfirmed && (
                    <button
                      className="btn btn-danger-outline cancel-booking-btn"
                      onClick={() => handleCancelBooking(booking._id, booking.bookingReference)}
                      disabled={cancelLoadingId === booking._id}
                    >
                      {cancelLoadingId === booking._id ? 'Cancelling...' : 'Cancel Booking'}
                    </button>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default MyBookings;
