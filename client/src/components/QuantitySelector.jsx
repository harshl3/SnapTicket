import React from 'react';

const QuantitySelector = ({ quantity, setQuantity, maxAvailable }) => {
  const handleDecrement = () => {
    if (quantity > 1) {
      setQuantity(quantity - 1);
    }
  };

  const handleIncrement = () => {
    if (quantity < maxAvailable) {
      setQuantity(quantity + 1);
    }
  };

  return (
    <div className="quantity-selector-container">
      <button
        type="button"
        className="qty-btn"
        onClick={handleDecrement}
        disabled={quantity <= 1}
        aria-label="Decrease quantity"
      >
        -
      </button>
      <span className="qty-value">{quantity}</span>
      <button
        type="button"
        className="qty-btn"
        onClick={handleIncrement}
        disabled={quantity >= maxAvailable || maxAvailable === 0}
        aria-label="Increase quantity"
      >
        +
      </button>
    </div>
  );
};

export default QuantitySelector;
