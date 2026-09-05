const mongoose = require('mongoose');

const connectDB = async () => {
  const uri = process.env.MONGO_URI;
  if (!uri) {
    throw new Error('MONGO_URI is required. Configure a persistent MongoDB/Atlas connection before starting the API.');
  }

  console.log('Connecting to MongoDB...');
  const conn = await mongoose.connect(uri, { serverSelectionTimeoutMS: 10000 });
  console.log(`MongoDB connected: ${conn.connection.host}`);
};

module.exports = connectDB;

