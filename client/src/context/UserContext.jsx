import React, { createContext, useContext, useState, useEffect } from 'react';
import { getUsers as fetchAllUsers } from '../services/api';

const UserContext = createContext();

export const UserProvider = ({ children }) => {
  const [users, setUsers] = useState([]);
  const [currentUser, setCurrentUser] = useState(null);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const initUsers = async () => {
      try {
        setLoadingUsers(true);
        const data = await fetchAllUsers();
        if (data.success && data.users) {
          setUsers(data.users);
          
          // Check localStorage for saved userId
          const savedUserId = localStorage.getItem('seatsmart_userId');
          if (savedUserId) {
            const matchedUser = data.users.find(u => u._id === savedUserId);
            if (matchedUser) {
              setCurrentUser(matchedUser);
            }
          }
        }
      } catch (err) {
        console.error('Failed to load users:', err);
        setError('Could not fetch mock users.');
      } finally {
        setLoadingUsers(false);
      }
    };

    initUsers();
  }, []);

  const selectUser = (user) => {
    setCurrentUser(user);
    if (user) {
      localStorage.setItem('seatsmart_userId', user._id);
    } else {
      localStorage.removeItem('seatsmart_userId');
    }
  };

  return (
    <UserContext.Provider
      value={{
        currentUser,
        setCurrentUser: selectUser,
        users,
        loadingUsers,
        error
      }}
    >
      {children}
    </UserContext.Provider>
  );
};

export const useUser = () => {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};
