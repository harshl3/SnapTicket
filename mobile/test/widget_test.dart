import 'package:flutter_test/flutter_test.dart';
import 'package:snapticket/models/user.dart';
import 'package:snapticket/models/event.dart';
import 'package:snapticket/models/booking.dart';
import 'package:snapticket/services/mock_api_service.dart';

void main() {
  group('SnapTicket Core Model & Service Tests', () {
    test('MockApiService loads users and events matching seed data', () async {
      final mockService = MockApiService();
      final users = await mockService.getUsers();
      final events = await mockService.getEvents();

      expect(users.isNotEmpty, true);
      expect(events.isNotEmpty, true);
      expect(users.length, greaterThanOrEqualTo(3));
      expect(users.first.name, 'Alice Johnson');
      expect(events.first.name, contains('AI & Future Technology Summit'));
    });

    test('Booking creation validates seat availability and generates BK-2026 reference', () async {
      final mockService = MockApiService();
      final users = await mockService.getUsers();
      final events = await mockService.getEvents();

      final user = users.first;
      final event = events.first;
      final initialSeats = event.availableSeats;

      final booking = await mockService.createBooking(
        userId: user.id,
        eventId: event.id,
        ticketsCount: 2,
      );

      expect(booking.bookingReference.startsWith('BK-'), true);
      expect(booking.ticketsCount, 2);
      expect(booking.isConfirmed, true);
      expect(booking.qrPayload, contains('SNAPTICKET|${booking.bookingReference}'));

      // Verify seat reduction
      final updatedEvent = await mockService.getEventById(event.id);
      expect(updatedEvent.availableSeats, initialSeats - 2);

      // Verify cancellation & seat restoration
      final cancelled = await mockService.cancelBooking(booking.id);
      expect(cancelled.isCancelled, true);

      final restoredEvent = await mockService.getEventById(event.id);
      expect(restoredEvent.availableSeats, initialSeats);
    });

    test('Booking throws error when attempting to book exceeding seats', () async {
      final mockService = MockApiService();
      final users = await mockService.getUsers();
      final events = await mockService.getEvents();

      final user = users.first;
      final event = events[3]; // Stand-up Comedy (0 available)

      expect(
        () => mockService.createBooking(
          userId: user.id,
          eventId: event.id,
          ticketsCount: 5,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Backend JSON schemas parse into models correctly', () {
      // Backend User JSON format
      final userJson = {
        '_id': '64a91b2c3d4e5f6a7b8c9d0e',
        'name': 'Alice Johnson',
        'email': 'alice@example.com',
        'interests': ['Technology', 'Music']
      };
      final user = User.fromJson(userJson);
      expect(user.id, '64a91b2c3d4e5f6a7b8c9d0e');
      expect(user.name, 'Alice Johnson');
      expect(user.interests.contains('Technology'), true);

      // Backend Event JSON format
      final eventJson = {
        '_id': '64a91b2c3d4e5f6a7b8c9d11',
        'name': 'AI & Future Technology Summit 2026',
        'category': 'Technology',
        'description': 'Summit description',
        'date': '2026-09-15',
        'time': '10:00 AM',
        'venue': 'Pune Convention Centre',
        'totalSeats': 100,
        'availableSeats': 80,
        'price': 499,
        'image': 'https://images.unsplash.com/photo-1591453089816-0fbb971b454c'
      };
      final event = Event.fromJson(eventJson);
      expect(event.id, '64a91b2c3d4e5f6a7b8c9d11');
      expect(event.price, 499.0);
      expect(event.imageUrl, contains('unsplash.com'));

      // Backend Booking JSON format with populated event
      final bookingJson = {
        '_id': '64a91b2c3d4e5f6a7b8c9d99',
        'bookingReference': 'BK-2026-892341',
        'userId': '64a91b2c3d4e5f6a7b8c9d0e',
        'eventId': '64a91b2c3d4e5f6a7b8c9d11',
        'quantity': 2,
        'totalAmount': 998,
        'bookingStatus': 'CONFIRMED',
        'createdAt': '2026-08-22T10:00:00.000Z',
        'event': {
          '_id': '64a91b2c3d4e5f6a7b8c9d11',
          'name': 'AI & Future Technology Summit 2026',
          'date': '2026-09-15',
          'time': '10:00 AM',
          'venue': 'Pune Convention Centre',
          'category': 'Technology'
        }
      };
      final booking = Booking.fromJson(bookingJson);
      expect(booking.id, '64a91b2c3d4e5f6a7b8c9d99');
      expect(booking.bookingReference, 'BK-2026-892341');
      expect(booking.ticketsCount, 2);
      expect(booking.totalPrice, 998.0);
      expect(booking.isConfirmed, true);
      expect(booking.event?.name, 'AI & Future Technology Summit 2026');
      expect(booking.qrPayload, 'SNAPTICKET|BK-2026-892341|64a91b2c3d4e5f6a7b8c9d11|64a91b2c3d4e5f6a7b8c9d0e');
    });
  });
}
