import axios from 'axios';

const API = axios.create({
  // VITE_API_BASE_URL is set by the deployment environment. The local default
  // keeps the web client convenient to run alongside the API.
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

export const getUsers = async () => {
  const response = await API.get('/users');
  return response.data;
};

export const getEvents = async (params = {}) => {
  const response = await API.get('/events', { params });
  return response.data;
};

export const getEventById = async (id) => {
  const response = await API.get(`/events/${id}`);
  return response.data;
};

export const createBooking = async (bookingData) => {
  const response = await API.post('/bookings', bookingData);
  return response.data;
};

export const getUserBookings = async (userId) => {
  const response = await API.get(`/bookings/user/${userId}`);
  return response.data;
};

export const cancelBooking = async (bookingId) => {
  const response = await API.patch(`/bookings/${bookingId}/cancel`);
  return response.data;
};

export default {
  getUsers,
  getEvents,
  getEventById,
  createBooking,
  getUserBookings,
  cancelBooking
};
