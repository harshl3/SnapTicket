const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Event name is required'],
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: ['Technology', 'Music', 'Sports', 'Entertainment', 'Business'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
    },
    date: {
      type: String,
      required: [true, 'Date is required'],
    },
    time: {
      type: String,
      required: [true, 'Time is required'],
    },
    venue: {
      type: String,
      required: [true, 'Venue is required'],
    },
    totalSeats: {
      type: Number,
      required: [true, 'Total seats is required'],
      min: [1, 'Total seats must be greater than 0'],
    },
    availableSeats: {
      type: Number,
      required: [true, 'Available seats is required'],
      min: [0, 'Available seats cannot be negative'],
      validate: {
        validator: function (value) {
          // If we perform updates like findOneAndUpdate, 'this' might refer to the query instead of document.
          // However, for initial creation, this works. Let's make it safe:
          if (this.totalSeats !== undefined) {
            return value <= this.totalSeats;
          }
          return true;
        },
        message: 'Available seats cannot exceed total seats',
      },
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
    },
    image: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Event', eventSchema);
