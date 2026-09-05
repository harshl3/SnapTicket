import React, { useState, useEffect } from 'react';
import SearchBar from '../components/SearchBar';
import CategoryFilter from '../components/CategoryFilter';
import EventList from '../components/EventList';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { getEvents } from '../services/api';

const Home = () => {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');

  const fetchEvents = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const params = {};
      if (search.trim() !== '') {
        params.search = search;
      }
      if (activeCategory !== 'All') {
        params.category = activeCategory;
      }

      const data = await getEvents(params);
      if (data.success) {
        setEvents(data.events);
      } else {
        setError(data.message || 'Failed to fetch events');
      }
    } catch (err) {
      console.error(err);
      setError('Could not connect to the server. Please check if the backend is running.');
    } finally {
      setLoading(false);
    }
  };

  // Fetch events when search or category changes
  useEffect(() => {
    const delayDebounceFn = setTimeout(() => {
      fetchEvents();
    }, 300); // debounce API requests

    return () => clearTimeout(delayDebounceFn);
  }, [search, activeCategory]);

  return (
    <div className="home-page">
      <header className="hero-section">
        <div className="hero-content">
          <h1 className="hero-title">Find Your Next Experience</h1>
          <p className="hero-subtitle">Discover exciting events and book your tickets in seconds.</p>
        </div>
      </header>

      <section className="search-filter-section">
        <SearchBar search={search} setSearch={setSearch} />
        <CategoryFilter activeCategory={activeCategory} setActiveCategory={setActiveCategory} />
      </section>

      <main className="events-main">
        {loading ? (
          <LoadingSpinner message="Searching for events..." />
        ) : error ? (
          <ErrorMessage message={error} onRetry={fetchEvents} />
        ) : (
          <EventList events={events} />
        )}
      </main>
    </div>
  );
};

export default Home;
