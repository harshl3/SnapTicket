import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { getEventById, createBooking } from '../services/api';
import { useUser } from '../context/UserContext';
import QuantitySelector from '../components/QuantitySelector';
import BookingSummary from '../components/BookingSummary';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';

const EventDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { currentUser } = useUser();

  const [event, setEvent] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [quantity, setQuantity] = useState(1);
  const [bookingLoading, setBookingLoading] = useState(false);
  const [bookingError, setBookingError] = useState(null);

  const fetchEventDetails = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getEventById(id);
      if (data.success) {
        setEvent(data.event);
        setQuantity(data.event.availableSeats > 0 ? 1 : 0);
      } else {
        setError(data.message || 'Failed to load event details');
      }
    } catch (err) {
      console.error(err);
      setError('Event not found or server is unreachable.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchEventDetails();
  }, [id]);

  const handleBookTickets = async () => {
    if (!currentUser) {
      setBookingError('Please select a user from the navbar before booking.');
      return;
    }

    if (quantity < 1) {
      setBookingError('Please select at least 1 ticket to book.');
      return;
    }

    try {
      setBookingLoading(true);
      setBookingError(null);
      
      const payload = {
        userId: currentUser._id,
        eventId: event._id,
        quantity: quantity
      };

      const data = await createBooking(payload);
      if (data.success && data.booking) {
        navigate(`/booking-success/${data.booking.bookingReference}`);
      } else {
        setBookingError(data.message || 'Booking failed.');
      }
    } catch (err) {
      console.error(err);
      const serverMsg = err.response?.data?.message || 'Server error. Seat reservation failed.';
      setBookingError(serverMsg);
    } finally {
      setBookingLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner message="Fetching event details..." />;
  }

  if (error || !event) {
    return (
      <div className="container py-5">
        <ErrorMessage message={error} onRetry={fetchEventDetails} />
        <div className="text-center mt-4">
          <Link to="/" className="btn btn-secondary">← Back to Events</Link>
        </div>
      </div>
    );
  }

  const isSoldOut = event.availableSeats === 0;

  const getFallbackImage = (cat) => {
    switch (cat) {
      case 'Technology':
        return 'https://images.unsplash.com/photo-1591453089816-0fbb971b454c?auto=format&fit=crop&q=80&w=800';
      case 'Music':
        return 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&q=80&w=800';
      case 'Sports':
        return 'https://images.unsplash.com/photo-1531415080290-bc9b8998063a?auto=format&fit=crop&q=80&w=800';
      case 'Entertainment':
        return 'https://images.unsplash.com/photo-1585699324551-f6c309eed262?auto=format&fit=crop&q=80&w=800';
      case 'Business':
        return 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&q=80&w=800';
      default:
        return 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&q=80&w=800';
    }
  };

  return (
    <div className="event-details-page">
      <Link to="/" className="back-link">← Back to Events</Link>
      
      <div className="event-details-container">
        <div className="event-details-info">
          <div className="details-image-container">
            <img src={event.image || getFallbackImage(event.category)} alt={event.name} className="details-image" />
            <div className="details-category">{event.category}</div>
          </div>
          
          <h2 className="details-title">{event.name}</h2>
          
          <div className="details-meta-grid">
            <div className="meta-card">
              <span className="meta-icon">📅</span>
              <div className="meta-text">
                <span className="meta-label">Date</span>
                <span className="meta-value">{event.date}</span>
              </div>
            </div>
            <div className="meta-card">
              <span className="meta-icon">🕒</span>
              <div className="meta-text">
                <span className="meta-label">Time</span>
                <span className="meta-value">{event.time}</span>
              </div>
            </div>
            <div className="meta-card">
              <span className="meta-icon">📍</span>
              <div className="meta-text">
                <span className="meta-label">Venue</span>
                <span className="meta-value">{event.venue}</span>
              </div>
            </div>
          </div>

          <div className="details-description">
            <h3>About this Event</h3>
            <p>{event.description}</p>
          </div>
        </div>

        <div className="event-details-sidebar">
          <div className="booking-panel">
            <div className="sidebar-price-row">
              <span className="price-label">Price per ticket</span>
              <span className="price-value">₹{event.price}</span>
            </div>

            <div className="sidebar-seats-row">
              <span className="seats-label">Availability</span>
              {isSoldOut ? (
                <span className="badge badge-soldout sidebar-badge">SOLD OUT</span>
              ) : event.availableSeats <= 5 ? (
                <span className="badge badge-danger sidebar-badge">Almost Sold Out ({event.availableSeats} left)</span>
              ) : (
                <span className="badge badge-success sidebar-badge">{event.availableSeats} left</span>
              )}
            </div>
            
            <div className="sidebar-capacity-total">
              Total Venue Capacity: <strong>{event.totalSeats} seats</strong>
            </div>

            <hr className="panel-divider" />

            {!isSoldOut && (
              <>
                <div className="selector-row">
                  <span className="selector-label">Select Quantity</span>
                  <QuantitySelector
                    quantity={quantity}
                    setQuantity={setQuantity}
                    maxAvailable={event.availableSeats}
                  />
                </div>

                <BookingSummary quantity={quantity} pricePerTicket={event.price} />
              </>
            )}

            {bookingError && (
              <div className="booking-error-message">
                <span>⚠️</span> {bookingError}
              </div>
            )}

            <button
              onClick={handleBookTickets}
              className={`btn btn-large w-full ${isSoldOut ? 'btn-disabled' : 'btn-primary'}`}
              disabled={isSoldOut || bookingLoading}
            >
              {bookingLoading ? 'Processing Booking...' : isSoldOut ? 'Sold Out' : 'Book Tickets Now'}
            </button>

            {!currentUser && (
              <p className="no-user-warning-hint">
                💡 Note: Select active user in the navigation bar to start booking.
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default EventDetails;
