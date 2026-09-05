import React from 'react';

const ErrorMessage = ({ message, onRetry }) => {
  return (
    <div className="error-message-box">
      <div className="error-icon">⚠️</div>
      <div className="error-content">
        <h4 className="error-title">An Error Occurred</h4>
        <p className="error-text">{message || 'Something went wrong. Please try again.'}</p>
        {onRetry && (
          <button className="btn btn-secondary error-retry-btn" onClick={onRetry}>
            Retry
          </button>
        )}
      </div>
    </div>
  );
};

export default ErrorMessage;
