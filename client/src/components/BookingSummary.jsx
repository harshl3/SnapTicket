import React from 'react';

const BookingSummary = ({ quantity, pricePerTicket }) => {
  const total = quantity * pricePerTicket;

  return (
    <div className="booking-summary-box">
      <h4 className="summary-title">Booking Summary</h4>
      <div className="summary-row">
        <span className="summary-label">Tickets:</span>
        <span className="summary-value">{quantity}</span>
      </div>
      <div className="summary-row">
        <span className="summary-label">Price per ticket:</span>
        <span className="summary-value">₹{pricePerTicket}</span>
      </div>
      <hr className="summary-divider" />
      <div className="summary-row total-row">
        <span className="summary-label">Total Amount:</span>
        <span className="summary-value">₹{total}</span>
      </div>
    </div>
  );
};

export default BookingSummary;
