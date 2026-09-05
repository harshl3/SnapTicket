import React from 'react';

const CategoryFilter = ({ activeCategory, setActiveCategory }) => {
  const categories = ['All', 'Technology', 'Music', 'Sports', 'Entertainment', 'Business'];

  return (
    <div className="category-filter-container">
      {categories.map((cat) => (
        <button
          key={cat}
          className={`category-filter-btn ${activeCategory === cat ? 'active' : ''}`}
          onClick={() => setActiveCategory(cat)}
        >
          {cat}
        </button>
      ))}
    </div>
  );
};

export default CategoryFilter;
