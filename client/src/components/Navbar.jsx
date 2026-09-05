import React from 'react';
import { Link, NavLink } from 'react-router-dom';
import UserSelector from './UserSelector';

const Navbar = () => {
  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-logo">
          <span className="logo-icon">🎟️</span>
          <span className="logo-text">SeatSmart</span>
        </Link>
        
        <div className="navbar-links">
          <NavLink to="/" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'} end>
            Home
          </NavLink>
          <NavLink to="/my-bookings" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>
            My Bookings
          </NavLink>
        </div>

        <div className="navbar-user">
          <UserSelector />
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
