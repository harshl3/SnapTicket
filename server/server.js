require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const errorHandler = require('./middleware/errorMiddleware');

const userRoutes = require('./routes/userRoutes');
const eventRoutes = require('./routes/eventRoutes');
const bookingRoutes = require('./routes/bookingRoutes');

const User = require('./models/User');
const Event = require('./models/Event');
const { users, events } = require('./data/seedData');

const app = express();

const autoSeed = async () => {
  try {
    const userCount = await User.countDocuments();
    const eventCount = await Event.countDocuments();
    
    if (userCount === 0 && eventCount === 0) {
      console.log('Database is empty. Seeding initial mock data...');
      
      const createdUsers = await User.insertMany(users);
      const createdEvents = await Event.insertMany(events);
      
      console.log(`Auto-seeded: ${createdUsers.length} users and ${createdEvents.length} events.`);
    }
  } catch (error) {
    console.error('Auto-seeding failed:', error.message);
  }
};

// Middleware
const allowedOrigins = (process.env.CLIENT_URL || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
app.use(cors({
  origin: allowedOrigins.length ? allowedOrigins : true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Test Route
app.get('/api/health', (req, res) => {
  res.status(200).json({ success: true, message: 'SnapTicket API is healthy' });
});

// Routes
app.use('/api/users', userRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/bookings', bookingRoutes);

// Error Handler Middleware
app.use(errorHandler);

const startServer = async () => {
  await connectDB();
  await autoSeed();
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, () => console.log(`SnapTicket API listening on port ${PORT}`));
};

if (require.main === module) {
  startServer().catch((error) => {
    console.error(`Unable to start SnapTicket API: ${error.message}`);
    process.exit(1);
  });
}

module.exports = { app, startServer };
