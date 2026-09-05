import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'event_provider.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isBookingInProgress = false;
  bool _isCancelling = false;
  String? _errorMessage;

  BookingProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isBookingInProgress => _isBookingInProgress;
  bool get isCancelling => _isCancelling;
  String? get errorMessage => _errorMessage;

  List<Booking> get confirmedBookings =>
      _bookings.where((b) => b.isConfirmed).toList();

  List<Booking> get cancelledBookings =>
      _bookings.where((b) => b.isCancelled).toList();

  Future<void> fetchUserBookings(String userId) async {
    if (userId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.getUserBookings(userId);
      _bookings = list;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> createBooking({
    required User user,
    required Event event,
    required int ticketsCount,
    required EventProvider eventProvider,
    String? notes,
  }) async {
    _isBookingInProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _apiService.createBooking(
        userId: user.id,
        eventId: event.id,
        ticketsCount: ticketsCount,
        notes: notes,
      );

      // Immediately sync available seats in EventProvider
      if (booking.event != null) {
        eventProvider.syncEventSeats(event.id, booking.event!.availableSeats);
      } else {
        eventProvider.syncEventSeats(event.id, event.availableSeats - ticketsCount);
      }

      // Add to beginning of current bookings list
      _bookings.insert(0, booking);

      return booking;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isBookingInProgress = false;
      notifyListeners();
    }
  }

  Future<Booking> cancelBooking({
    required String bookingId,
    required EventProvider eventProvider,
  }) async {
    _isCancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBooking = await _apiService.cancelBooking(bookingId);

      // Update in local booking list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }

      // Sync restored seats in EventProvider
      if (updatedBooking.event != null) {
        eventProvider.syncEventSeats(
          updatedBooking.eventId,
          updatedBooking.event!.availableSeats,
        );
      }

      return updatedBooking;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }
}
