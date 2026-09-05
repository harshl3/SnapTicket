const mongoose = require('mongoose');
const Booking = require('../models/Booking');
const Event = require('../models/Event');
const User = require('../models/User');

// Helper to generate a unique readable booking reference
const generateBookingReference = () => {
  const year = new Date().getFullYear();
  // BK-YYYY-XXXXXX where XXXXXX is a random numeric code
  const randomNum = Math.floor(100000 + Math.random() * 900000);
  return `BK-${year}-${randomNum}`;
};

const formatBooking = (booking, event) => ({
  _id: booking._id,
  bookingReference: booking.bookingReference,
  userId: booking.userId,
  eventId: booking.eventId?._id || booking.eventId,
  quantity: booking.quantity,
  totalAmount: booking.totalAmount,
  bookingStatus: booking.bookingStatus,
  createdAt: booking.createdAt,
  event: event || (booking.eventId && typeof booking.eventId === 'object' ? booking.eventId : null),
});

// @desc    Create a new booking
// @route   POST /api/bookings
// @access  Public
const createBooking = async (req, res, next) => {
  const { userId, eventId, quantity } = req.body;

  // Step 1: Validate fields presence
  if (!userId || !eventId || quantity === undefined) {
    res.status(400);
    return next(new Error('User ID, Event ID, and quantity are required'));
  }

  // Step 2: Validate quantity is a positive integer
  const qty = parseInt(quantity, 10);
  if (isNaN(qty) || qty <= 0) {
    res.status(400);
    return next(new Error('Quantity must be a positive integer'));
  }

  try {
    // Step 3: Confirm that the user exists
    const userExists = await User.exists({ _id: userId });
    if (!userExists) {
      res.status(400);
      return next(new Error('User not found'));
    }

    // Step 4: Atomically check and decrease available seats
    const updatedEvent = await Event.findOneAndUpdate(
      {
        _id: eventId,
        availableSeats: { $gte: qty }
      },
      {
        $inc: { availableSeats: -qty }
      },
      {
        new: true, // return the modified document
        runValidators: true
      }
    );

    // If no event is returned, it means either:
    // a) The event doesn't exist.
    // b) There are insufficient seats.
    if (!updatedEvent) {
      const eventExists = await Event.exists({ _id: eventId });
      if (!eventExists) {
        res.status(404);
        return next(new Error('Event not found'));
      } else {
        res.status(400);
        return next(new Error('Insufficient seats available'));
      }
    }

    // Step 5: Calculate total amount
    const totalAmount = updatedEvent.price * qty;

    // Step 6: Generate a unique booking reference
    let bookingReference;
    let referenceIsUnique = false;
    let retries = 5;

    while (!referenceIsUnique && retries > 0) {
      bookingReference = generateBookingReference();
      const existingRef = await Booking.exists({ bookingReference });
      if (!existingRef) {
        referenceIsUnique = true;
      }
      retries--;
    }

    if (!referenceIsUnique) {
      // Fallback: rollback seats and throw error
      await Event.findByIdAndUpdate(eventId, { $inc: { availableSeats: qty } });
      res.status(500);
      return next(new Error('Failed to generate a unique booking reference'));
    }

    // Step 7: Create the booking
    let booking;
    try {
      booking = await Booking.create({
        bookingReference,
        userId,
        eventId,
        quantity: qty,
        totalAmount,
        bookingStatus: 'CONFIRMED'
      });
    } catch (bookingError) {
      // Step 8: Rollback if Booking.create fails
      console.error('Booking creation failed, rolling back seats:', bookingError);
      await Event.findByIdAndUpdate(eventId, { $inc: { availableSeats: qty } });
      throw bookingError;
    }

    // Step 9: Return booking confirmation
    res.status(201).json({
      success: true,
      message: 'Booking confirmed successfully',
      booking: formatBooking(booking, updatedEvent),
    });

  } catch (error) {
    next(error);
  }
};

// @desc    Get all bookings for a user
// @route   GET /api/bookings/user/:userId
// @access  Public
const getUserBookings = async (req, res, next) => {
  try {
    const { userId } = req.params;

    // Confirm that the user exists
    const userExists = await User.exists({ _id: userId });
    if (!userExists) {
      res.status(404);
      return next(new Error('User not found'));
    }

    const bookings = await Booking.find({ userId })
      .populate({
        path: 'eventId'
      })
      .sort({ createdAt: -1 });

    const formattedBookings = bookings.map((booking) => formatBooking(booking));

    res.status(200).json({
      success: true,
      bookings: formattedBookings
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Cancel a booking
// @route   PATCH /api/bookings/:bookingId/cancel
// @access  Public
const cancelBooking = async (req, res, next) => {
  try {
    const { bookingId } = req.params;

    // The conditional update means two simultaneous cancellation requests cannot
    // restore the same seats twice.
    const booking = await Booking.findOneAndUpdate(
      { _id: bookingId, bookingStatus: 'CONFIRMED' },
      { $set: { bookingStatus: 'CANCELLED' } },
      { new: true }
    );
    if (!booking) {
      const exists = await Booking.exists({ _id: bookingId });
      res.status(exists ? 400 : 404);
      return next(new Error(exists ? 'Booking is already cancelled' : 'Booking not found'));
    }

    // A confirmed booking reserved these seats, so one conditional cancellation
    // restores them exactly once.
    const event = await Event.findById(booking.eventId);
    if (event) {
      const restoredSeats = event.availableSeats + booking.quantity;
      event.availableSeats = Math.min(event.totalSeats, restoredSeats);
      await event.save();
    }

    res.status(200).json({
      success: true,
      message: 'Booking cancelled successfully',
      booking: formatBooking(booking, event)
    });

  } catch (error) {
    next(error);
  }
};

module.exports = {
  createBooking,
  getUserBookings,
  cancelBooking
};
