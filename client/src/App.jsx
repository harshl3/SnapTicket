import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { UserProvider } from './context/UserContext';
import Navbar from './components/Navbar';
import Home from './pages/Home';
import EventDetails from './pages/EventDetails';
import BookingSuccess from './pages/BookingSuccess';
import MyBookings from './pages/MyBookings';
import NotFound from './pages/NotFound';

function App() {
  return (
    <UserProvider>
      <Router>
        <div className="app-layout">
          <Navbar />
          <main className="main-content">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/events/:id" element={<EventDetails />} />
              <Route path="/booking-success/:bookingReference" element={<BookingSuccess />} />
              <Route path="/my-bookings" element={<MyBookings />} />
              <Route path="*" element={<NotFound />} />
            </Routes>
          </main>
          <footer className="footer">
            <div className="footer-container">
              <p className="footer-text">© 2026 SeatSmart. Discover, book, and manage event tickets effortlessly.</p>
            </div>
          </footer>
        </div>
      </Router>
    </UserProvider>
  );
}

export default App;
