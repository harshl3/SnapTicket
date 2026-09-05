import React from 'react';
import { Link } from 'react-router-dom';

const EventCard = ({ event }) => {
  const { _id, name, category, date, venue, price, availableSeats, totalSeats, image } = event;

  // Visual cues for seat availability states
  let availabilityBadge = null;
  if (availableSeats === 0) {
    availabilityBadge = <span className="badge badge-soldout">Sold Out</span>;
  } else if (availableSeats <= 5) {
    availabilityBadge = <span className="badge badge-danger">Only {availableSeats} left!</span>;
  } else if (availableSeats <= 20) {
    availabilityBadge = <span className="badge badge-warning">Filling Fast ({availableSeats} left)</span>;
  } else {
    availabilityBadge = <span className="badge badge-success">{availableSeats} Available</span>;
  }

  // Fallback image based on category if the image is missing
  const getFallbackImage = (cat) => {
    switch (cat) {
      case 'Technology':
        return 'https://images.unsplash.com/photo-1591453089816-0fbb971b454c?auto=format&fit=crop&q=80&w=400';
      case 'Music':
        return 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&q=80&w=400';
      case 'Sports':
        return 'https://images.unsplash.com/photo-1531415080290-bc9b8998063a?auto=format&fit=crop&q=80&w=400';
      case 'Entertainment':
        return 'https://images.unsplash.com/photo-1585699324551-f6c309eed262?auto=format&fit=crop&q=80&w=400';
      case 'Business':
        return 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&q=80&w=400';
      default:
        return 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&q=80&w=400';
    }
  };

  const eventImage = image || getFallbackImage(category);

  return (
    <div className="event-card">
      <div className="event-card-image-container">
        <img src={eventImage} alt={name} className="event-card-image" loading="lazy" />
        <div className="event-card-category-badge">{category}</div>
      </div>
      <div className="event-card-content">
        <div className="event-card-header">
          <h3 className="event-card-title" title={name}>{name}</h3>
        </div>
        <div className="event-card-details">
          <div className="event-detail-item">
            <span className="icon">📅</span> {date}
          </div>
          <div className="event-detail-item">
            <span className="icon">📍</span> {venue}
          </div>
        </div>
        <div className="event-card-footer">
          <div className="event-card-price-seats">
            <div className="event-card-price">₹{price}</div>
            <div className="event-card-badge-container">{availabilityBadge}</div>
          </div>
          <Link to={`/events/${_id}`} className="btn btn-primary event-card-button">
            View Details
          </Link>
        </div>
      </div>
    </div>
  );
};

export default EventCard;
