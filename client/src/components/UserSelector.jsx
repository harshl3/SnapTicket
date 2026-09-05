import React from 'react';
import { useUser } from '../context/UserContext';

const UserSelector = () => {
  const { currentUser, setCurrentUser, users, loadingUsers } = useUser();

  const handleChange = (e) => {
    const selectedId = e.target.value;
    if (!selectedId) {
      setCurrentUser(null);
    } else {
      const selectedUser = users.find(u => u._id === selectedId);
      setCurrentUser(selectedUser);
    }
  };

  if (loadingUsers) {
    return <span className="user-selector-loading">Loading users...</span>;
  }

  return (
    <div className="user-selector-container">
      <label htmlFor="user-select" className="user-selector-label">Active User:</label>
      <select
        id="user-select"
        className="user-selector-select"
        value={currentUser ? currentUser._id : ''}
        onChange={handleChange}
      >
        <option value="">-- Select User --</option>
        {users.map(user => (
          <option key={user._id} value={user._id}>
            {user.name}
          </option>
        ))}
      </select>
    </div>
  );
};

export default UserSelector;
