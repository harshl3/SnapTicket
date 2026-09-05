import React from 'react';

const SearchBar = ({ search, setSearch }) => {
  return (
    <div className="search-bar-container">
      <span className="search-icon">🔍</span>
      <input
        type="text"
        className="search-input"
        placeholder="Search events by name or description..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      {search && (
        <button className="search-clear-btn" onClick={() => setSearch('')} aria-label="Clear search">
          ✕
        </button>
      )}
    </div>
  );
};

export default SearchBar;
