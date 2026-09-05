import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/event.dart';
import '../models/booking.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

/// Real HTTP implementation of [ApiService] communicating with the Node.js/Express + MongoDB backend.
///
/// Endpoints:
/// - GET   /api/users
/// - GET   /api/users/:id
/// - GET   /api/events
/// - GET   /api/events/:id
/// - POST  /api/bookings
/// - GET   /api/bookings/user/:userId
/// - PATCH /api/bookings/:bookingId/cancel
class RealApiService implements ApiService {
  final http.Client _client;

  RealApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  Future<List<User>> getUsers() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}');
    try {
      final response = await _client
          .get(url, headers: _defaultHeaders)
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List rawList = [];
        if (data is Map) {
          if (data['users'] != null) {
            rawList = data['users'] as List;
          } else if (data['data'] != null) {
            rawList = data['data'] as List;
          }
        } else if (data is List) {
          rawList = data;
        }
        return rawList.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load users (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error while fetching users: $e');
    }
  }

  @override
  Future<User> getUserById(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userByIdEndpoint(id)}');
    try {
      final response = await _client
          .get(url, headers: _defaultHeaders)
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final Map<String, dynamic> userMap = data is Map && data['user'] != null
            ? data['user'] as Map<String, dynamic>
            : (data is Map && data['data'] != null ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>);
        return User.fromJson(userMap);
      } else {
        throw Exception('Failed to load user (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error while fetching user: $e');
    }
  }

  @override
  Future<List<Event>> getEvents() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventsEndpoint}');
    try {
      final response = await _client
          .get(url, headers: _defaultHeaders)
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List rawList = [];
        if (data is Map) {
          if (data['events'] != null) {
            rawList = data['events'] as List;
          } else if (data['data'] != null) {
            rawList = data['data'] as List;
          }
        } else if (data is List) {
          rawList = data;
        }
        return rawList.map((item) => Event.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load events (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error while fetching events: $e');
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventByIdEndpoint(id)}');
    try {
      final response = await _client
          .get(url, headers: _defaultHeaders)
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final Map<String, dynamic> eventMap = data is Map && data['event'] != null
            ? data['event'] as Map<String, dynamic>
            : (data is Map && data['data'] != null ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>);
        return Event.fromJson(eventMap);
      } else {
        throw Exception('Failed to load event (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error while fetching event: $e');
    }
  }

  @override
  Future<Booking> createBooking({
    required String userId,
    required String eventId,
    required int ticketsCount,
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookingsEndpoint}');
    try {
      // Backend expects 'quantity', 'userId', 'eventId'
      final payload = jsonEncode({
        'userId': userId,
        'eventId': eventId,
        'quantity': ticketsCount,
      });

      final response = await _client
          .post(url, headers: _defaultHeaders, body: payload)
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final Map<String, dynamic> bookingMap = data is Map && data['booking'] != null
            ? data['booking'] as Map<String, dynamic>
            : (data is Map && data['data'] != null ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>);
        return Booking.fromJson(bookingMap);
      } else {
        final dynamic errorBody = jsonDecode(response.body);
        final errorMessage = errorBody is Map ? (errorBody['message'] ?? response.body) : response.body;
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('Booking failed: $e');
    }
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userBookingsEndpoint(userId)}');
    try {
      final response = await _client
          .get(url, headers: _defaultHeaders)
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List rawList = [];
        if (data is Map) {
          if (data['bookings'] != null) {
            rawList = data['bookings'] as List;
          } else if (data['data'] != null) {
            rawList = data['data'] as List;
          }
        } else if (data is List) {
          rawList = data;
        }
        return rawList.map((item) => Booking.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load user bookings (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error while fetching user bookings: $e');
    }
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cancelBookingEndpoint(bookingId)}');
    try {
      final response = await _client
          .patch(url, headers: _defaultHeaders)
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final Map<String, dynamic> bookingMap = data is Map && data['booking'] != null
            ? data['booking'] as Map<String, dynamic>
            : (data is Map && data['data'] != null ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>);
        return Booking.fromJson(bookingMap);
      } else {
        final dynamic errorBody = jsonDecode(response.body);
        final errorMessage = errorBody is Map ? (errorBody['message'] ?? response.body) : response.body;
        throw Exception('$errorMessage');
      }
    } catch (e) {
      throw Exception('Cancellation failed: $e');
    }
  }
}
