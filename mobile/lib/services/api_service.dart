import '../models/user.dart';
import '../models/event.dart';
import '../models/booking.dart';
import '../utils/api_constants.dart';
import 'mock_api_service.dart';
import 'real_api_service.dart';

/// Abstract API Service interface defining the contract for data operations.
/// Both [MockApiService] and [RealApiService] implement this interface.
abstract class ApiService {
  /// Factory constructor that returns the active implementation based on [ApiConstants.useMockApi].
  factory ApiService() {
    if (ApiConstants.useMockApi) {
      return MockApiService();
    } else {
      return RealApiService();
    }
  }

  // Users
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);

  // Events
  Future<List<Event>> getEvents();
  Future<Event> getEventById(String id);

  // Bookings
  Future<Booking> createBooking({
    required String userId,
    required String eventId,
    required int ticketsCount,
    String? notes,
  });

  Future<List<Booking>> getUserBookings(String userId);

  Future<Booking> cancelBooking(String bookingId);
}
