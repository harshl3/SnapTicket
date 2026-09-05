import React from 'react';
import EventCard from './EventCard';

const EventList = ({ events }) => {
  if (!events || events.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-state-icon">🔍</div>
        <h3 className="empty-state-title">No Events Found</h3>
        <p className="empty-state-text">We couldn't find any events matching your current search or category selections. Try adjusting your search query or switching categories.</p>
      </div>
    );
  }

  return (
    <div className="event-grid">
      {events.map((event) => (
        <EventCard key={event._id} event={event} />
      ))}
    </div>
  );
};

export default EventList;
