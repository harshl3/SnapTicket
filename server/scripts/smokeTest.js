/**
 * End-to-end API check for a local server or deployed Render service.
 * It creates and then cancels one booking, so the selected event's inventory
 * is restored before the script finishes.
 */
const baseUrl = (process.env.API_BASE_URL || 'http://127.0.0.1:5000/api').replace(/\/$/, '');

const request = async (path, options = {}) => {
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`${options.method || 'GET'} ${path} failed (${response.status}): ${body.message || response.statusText}`);
  return body;
};

const run = async () => {
  const health = await request('/health');
  const users = await request('/users');
  const events = await request('/events');
  const user = users.users?.[0];
  const event = events.events?.find((item) => item.availableSeats > 0);

  if (!health.success || !user || !event) {
    throw new Error('Health check, seeded user, or an event with seats available is missing');
  }

  const created = await request('/bookings', {
    method: 'POST',
    body: JSON.stringify({ userId: user._id, eventId: event._id, quantity: 1 }),
  });
  const bookingId = created.booking?._id;
  if (!bookingId) throw new Error('Booking response did not include its _id');

  const bookings = await request(`/bookings/user/${user._id}`);
  if (!bookings.bookings?.some((booking) => booking._id === bookingId)) {
    throw new Error('Created booking was not returned by the user bookings endpoint');
  }

  const cancelled = await request(`/bookings/${bookingId}/cancel`, { method: 'PATCH' });
  if (cancelled.booking?.bookingStatus !== 'CANCELLED') {
    throw new Error('Booking was not cancelled');
  }

  console.log(`SnapTicket API smoke test passed: ${baseUrl}`);
};

run().catch((error) => {
  console.error(`SnapTicket API smoke test failed: ${error.message}`);
  process.exit(1);
});
