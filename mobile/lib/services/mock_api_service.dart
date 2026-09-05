import 'dart:async';
import 'dart:math';
import '../models/user.dart';
import '../models/event.dart';
import '../models/booking.dart';
import 'api_service.dart';

/// In-memory Mock API Service simulating backend operations with realistic seed data and state.
class MockApiService implements ApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;

  MockApiService._internal() {
    _initMockData();
  }

  late List<User> _users;
  late List<Event> _events;
  late List<Booking> _bookings;

  void _initMockData() {
    // Aligned with team backend seed data
    _users = [
      const User(
        id: 'usr_001',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        phone: '+91 98765 43210',
        role: 'Tech Enthusiast',
        interests: ['Technology', 'Music'],
      ),
      const User(
        id: 'usr_002',
        name: 'Bob Smith',
        email: 'bob@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        phone: '+91 98234 56789',
        role: 'Sports Fan',
        interests: ['Sports', 'Entertainment'],
      ),
      const User(
        id: 'usr_003',
        name: 'Charlie Brown',
        email: 'charlie@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        phone: '+91 91234 56780',
        role: 'Founder',
        interests: ['Business', 'Technology'],
      ),
      const User(
        id: 'usr_004',
        name: 'Sophia Chen',
        email: 'sophia@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        phone: '+91 99887 76655',
        role: 'UX Researcher',
        interests: ['Technology', 'Entertainment'],
      ),
      const User(
        id: 'usr_005',
        name: 'Marcus Vance',
        email: 'marcus@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        phone: '+91 94455 66778',
        role: 'Event Producer',
        interests: ['Music', 'Business'],
      ),
    ];

    _events = [
      const Event(
        id: 'evt_001',
        name: 'AI & Future Technology Summit 2026',
        category: 'Technology',
        description: 'Explore the limits of artificial intelligence, neural networks, and future technologies. Join industry leaders for keynote presentations, panels, and live coding demos.',
        date: '2026-09-15',
        time: '10:00 AM',
        venue: 'Pune Convention Centre',
        totalSeats: 100,
        availableSeats: 78,
        price: 499.0,
        imageUrl: 'https://images.unsplash.com/photo-1591453089816-0fbb971b454c?auto=format&fit=crop&q=80&w=600',
        isFeatured: true,
        organizer: 'NextGen Tech Foundation',
        rating: 4.9,
      ),
      const Event(
        id: 'evt_002',
        name: 'Live Rock Music Festival 2026',
        category: 'Music',
        description: 'An open-air music festival featuring top rock bands, acoustic acts, and amazing street food. Bring your friends for a night of incredible rhythms and vibes.',
        date: '2026-10-05',
        time: '05:30 PM',
        venue: 'Sunset Meadows Arena',
        totalSeats: 100,
        availableSeats: 20,
        price: 899.0,
        imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&q=80&w=600',
        isFeatured: true,
        organizer: 'Pulse Music Festival',
        rating: 4.8,
      ),
      const Event(
        id: 'evt_003',
        name: 'National Cricket Championship Finals',
        category: 'Sports',
        description: 'Experience the ultimate rivalry live from the stadium! Two of the best teams go head-to-head for the historic championship trophy.',
        date: '2026-08-30',
        time: '02:00 PM',
        venue: 'Wankhede Cricket Stadium',
        totalSeats: 100,
        availableSeats: 5,
        price: 1200.0,
        imageUrl: 'https://images.unsplash.com/photo-1531415080290-bc9b8998063a?auto=format&fit=crop&q=80&w=600',
        isFeatured: true,
        organizer: 'Sports Authority & League',
        rating: 4.7,
      ),
      const Event(
        id: 'evt_004',
        name: 'Stand-up Comedy Night featuring Zakir',
        category: 'Entertainment',
        description: 'Get ready for a night of non-stop laughter and brilliant observational humor. Food and beverages are available at the venue.',
        date: '2026-09-02',
        time: '08:00 PM',
        venue: 'The Laugh Club',
        totalSeats: 50,
        availableSeats: 0,
        price: 350.0,
        imageUrl: 'https://images.unsplash.com/photo-1585699324551-f6c309eed262?auto=format&fit=crop&q=80&w=600',
        isFeatured: false,
        organizer: 'LaughLab India',
        rating: 4.8,
      ),
      const Event(
        id: 'evt_005',
        name: 'Startup Leadership and Networking Meetup',
        category: 'Business',
        description: 'Connect with local startup founders, angel investors, and experienced product leaders. Exchange ideas, pitching tips, and explore partnership opportunities.',
        date: '2026-09-22',
        time: '06:00 PM',
        venue: 'WeWork Hub, Bangalore',
        totalSeats: 150,
        availableSeats: 150,
        price: 199.0,
        imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&q=80&w=600',
        isFeatured: false,
        organizer: 'Founders Circle',
        rating: 4.6,
      ),
      const Event(
        id: 'evt_006',
        name: 'Innovation Expo & Startup Showroom',
        category: 'Technology',
        description: 'Interact with cutting edge gadgets, new software demos, and smart appliances. Meet innovators presenting their latest patented tech concepts.',
        date: '2026-11-12',
        time: '11:00 AM',
        venue: 'Pragati Maidan Exhibition Hall',
        totalSeats: 80,
        availableSeats: 40,
        price: 150.0,
        imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&q=80&w=600',
        isFeatured: false,
        organizer: 'TechShowcase India',
        rating: 4.7,
      ),
      const Event(
        id: 'evt_007',
        name: 'Classical Indian Music & Fusion Evening',
        category: 'Music',
        description: 'Immerse yourself in soul-stirring classical ragas on sitar and tabla, followed by a contemporary fusion set by international artists.',
        date: '2026-09-28',
        time: '06:30 PM',
        venue: 'Royal Opera House',
        totalSeats: 120,
        availableSeats: 10,
        price: 600.0,
        imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&q=80&w=600',
        isFeatured: false,
        organizer: 'Heritage Arts Trust',
        rating: 4.9,
      ),
      const Event(
        id: 'evt_008',
        name: 'Product Strategy & Scale Conference 2026',
        category: 'Business',
        description: 'A premium masterclass event discussing SaaS growth loops, user acquisition channels, metrics frameworks, and monetization scaling strategies.',
        date: '2026-10-18',
        time: '09:00 AM',
        venue: 'Taj Lands End',
        totalSeats: 200,
        availableSeats: 180,
        price: 1500.0,
        imageUrl: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?auto=format&fit=crop&q=80&w=600',
        isFeatured: false,
        organizer: 'ProductScale Guild',
        rating: 4.8,
      ),
    ];

    _bookings = [
      Booking(
        id: 'bk_001',
        bookingReference: 'BK-2026-849201',
        userId: 'usr_001',
        eventId: 'evt_001',
        event: _events[0],
        ticketsCount: 2,
        unitPrice: 499.0,
        totalPrice: 998.0,
        status: BookingStatus.confirmed,
        bookedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Booking(
        id: 'bk_002',
        bookingReference: 'BK-2026-193482',
        userId: 'usr_001',
        eventId: 'evt_002',
        event: _events[1],
        ticketsCount: 1,
        unitPrice: 899.0,
        totalPrice: 899.0,
        status: BookingStatus.confirmed,
        bookedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Booking(
        id: 'bk_003',
        bookingReference: 'BK-2026-728193',
        userId: 'usr_002',
        eventId: 'evt_003',
        event: _events[2],
        ticketsCount: 1,
        unitPrice: 1200.0,
        totalPrice: 1200.0,
        status: BookingStatus.confirmed,
        bookedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_users);
  }

  @override
  Future<User> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _users.firstWhere(
      (u) => u.id == id,
      orElse: () => throw Exception('User not found with ID: $id'),
    );
  }

  @override
  Future<List<Event>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_events);
  }

  @override
  Future<Event> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _events.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Event not found with ID: $id'),
    );
  }

  @override
  Future<Booking> createBooking({
    required String userId,
    required String eventId,
    required int ticketsCount,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 1. Verify User
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) {
      throw Exception('User not found');
    }

    // 2. Verify Event
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found');
    }

    final targetEvent = _events[eventIndex];

    // 3. Verify Quantity
    if (ticketsCount <= 0) {
      throw Exception('Quantity must be a positive integer');
    }

    // 4. Verify Seat Availability
    if (ticketsCount > targetEvent.availableSeats) {
      throw Exception('Insufficient seats available');
    }

    // 5. Decrement seats
    final updatedEvent = targetEvent.copyWith(
      availableSeats: targetEvent.availableSeats - ticketsCount,
    );
    _events[eventIndex] = updatedEvent;

    // 6. Generate backend-aligned booking reference (BK-YYYY-XXXXXX)
    final year = DateTime.now().year;
    final randomNum = 100000 + Random().nextInt(900000);
    final bookingRef = 'BK-$year-$randomNum';
    final bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';

    // 7. Create booking record
    final newBooking = Booking(
      id: bookingId,
      bookingReference: bookingRef,
      userId: userId,
      eventId: eventId,
      event: updatedEvent,
      ticketsCount: ticketsCount,
      unitPrice: targetEvent.price,
      totalPrice: targetEvent.price * ticketsCount,
      status: BookingStatus.confirmed,
      bookedAt: DateTime.now(),
      notes: notes,
    );

    _bookings.insert(0, newBooking);
    return newBooking;
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final userBookings = _bookings.where((b) => b.userId == userId).map((b) {
      final currentEvent = _events.firstWhere(
        (e) => e.id == b.eventId,
        orElse: () => b.event ?? const Event(
          id: 'unknown',
          name: 'Archived Event',
          category: 'General',
          description: '',
          date: '',
          time: '',
          venue: '',
          totalSeats: 0,
          availableSeats: 0,
          price: 0,
          imageUrl: '',
        ),
      );
      return b.copyWith(event: currentEvent);
    }).toList();

    return List.unmodifiable(userBookings);
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex == -1) {
      throw Exception('Booking not found');
    }

    final targetBooking = _bookings[bookingIndex];

    if (targetBooking.status == BookingStatus.cancelled) {
      throw Exception('Booking is already cancelled');
    }

    // Restore seats
    final eventIndex = _events.indexWhere((e) => e.id == targetBooking.eventId);
    Event? updatedEvent;
    if (eventIndex != -1) {
      final evt = _events[eventIndex];
      final restoredSeats = min(evt.totalSeats, evt.availableSeats + targetBooking.ticketsCount);
      updatedEvent = evt.copyWith(availableSeats: restoredSeats);
      _events[eventIndex] = updatedEvent;
    }

    final cancelledBooking = targetBooking.copyWith(
      status: BookingStatus.cancelled,
      event: updatedEvent ?? targetBooking.event,
    );
    _bookings[bookingIndex] = cancelledBooking;

    return cancelledBooking;
  }
}
