const Event = require('../models/Event');

// @desc    Get all events with optional search & category filter
// @route   GET /api/events
// @access  Public
const getEvents = async (req, res, next) => {
  try {
    const { search, category } = req.query;
    let query = {};

    if (category && category !== 'All' && category !== '') {
      query.category = category;
    }

    if (search && search.trim() !== '') {
      const searchRegex = new RegExp(search, 'i');
      query.$or = [
        { name: searchRegex },
        { description: searchRegex }
      ];
    }

    const events = await Event.find(query);
    res.status(200).json({
      success: true,
      count: events.length,
      events
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single event by ID
// @route   GET /api/events/:id
// @access  Public
const getEventById = async (req, res, next) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      res.status(404);
      throw new Error('Event not found');
    }
    res.status(200).json({
      success: true,
      event
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getEvents,
  getEventById
};
