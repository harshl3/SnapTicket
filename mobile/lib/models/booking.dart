import 'event.dart';

enum BookingStatus {
  confirmed('CONFIRMED'),
  cancelled('CANCELLED');

  final String value;
  const BookingStatus(this.value);

  static BookingStatus fromString(String status) {
    if (status.toUpperCase() == 'CANCELLED') {
      return BookingStatus.cancelled;
    }
    return BookingStatus.confirmed;
  }
}

class Booking {
  final String id;
  final String bookingReference;
  final String userId;
  final String eventId;
  final Event? event;
  final int ticketsCount;
  final double unitPrice;
  final double totalPrice;
  final BookingStatus status;
  final DateTime bookedAt;
  final String? notes;

  const Booking({
    required this.id,
    required this.bookingReference,
    required this.userId,
    required this.eventId,
    this.event,
    required this.ticketsCount,
    required this.unitPrice,
    required this.totalPrice,
    this.status = BookingStatus.confirmed,
    required this.bookedAt,
    this.notes,
  });

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Deterministic QR payload for demo and digital check-in
  String get qrPayload {
    final effectiveEventId = eventId.isNotEmpty
        ? eventId
        : ((event != null && event!.id.isNotEmpty) ? event!.id : 'EVENT');
    final effectiveUserId = userId.isNotEmpty ? userId : 'USER';
    return 'SNAPTICKET|$bookingReference|$effectiveEventId|$effectiveUserId';
  }

  factory Booking.fromJson(Map<String, dynamic> json, {Event? resolvedEvent}) {
    final id = json['_id'] as String? ?? json['id'] as String? ?? '';
    final ref = json['bookingReference'] as String? ??
        json['reference'] as String? ??
        'BK-${DateTime.now().year}-${(100000 + DateTime.now().millisecondsSinceEpoch % 900000)}';

    final userId = json['userId'] is String
        ? json['userId'] as String
        : (json['userId'] is Map ? json['userId']['_id'] ?? json['userId']['id'] : '') ?? '';

    final eventId = json['eventId'] is String
        ? json['eventId'] as String
        : (json['eventId'] is Map ? json['eventId']['_id'] ?? json['eventId']['id'] : '') ?? '';

    // If event is populated in JSON (backend sends populated object)
    Event? attachedEvent = resolvedEvent;
    if (attachedEvent == null && json['event'] is Map) {
      attachedEvent = Event.fromJson(json['event'] as Map<String, dynamic>);
    } else if (attachedEvent == null && json['eventId'] is Map) {
      attachedEvent = Event.fromJson(json['eventId'] as Map<String, dynamic>);
    }

    final quantity = (json['quantity'] as num?)?.toInt() ??
        (json['ticketsCount'] as num?)?.toInt() ??
        1;

    final totalAmount = (json['totalAmount'] as num?)?.toDouble() ??
        (json['totalPrice'] as num?)?.toDouble() ??
        (json['total'] as num?)?.toDouble() ??
        0.0;

    final unitPrice = (json['unitPrice'] as num?)?.toDouble() ??
        (quantity > 0 ? totalAmount / quantity : 0.0);

    final statusStr = json['bookingStatus'] as String? ??
        json['status'] as String? ??
        'CONFIRMED';

    DateTime bookedDate = DateTime.now();
    if (json['createdAt'] != null) {
      bookedDate = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else if (json['bookedAt'] != null) {
      bookedDate = DateTime.tryParse(json['bookedAt'].toString()) ?? DateTime.now();
    }

    return Booking(
      id: id,
      bookingReference: ref,
      userId: userId,
      eventId: eventId.isNotEmpty ? eventId : (attachedEvent?.id ?? ''),
      event: attachedEvent,
      ticketsCount: quantity,
      unitPrice: unitPrice,
      totalPrice: totalAmount,
      status: BookingStatus.fromString(statusStr),
      bookedAt: bookedDate,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'bookingReference': bookingReference,
      'userId': userId,
      'eventId': eventId,
      'quantity': ticketsCount,
      'ticketsCount': ticketsCount,
      'unitPrice': unitPrice,
      'totalAmount': totalPrice,
      'totalPrice': totalPrice,
      'bookingStatus': status.value,
      'status': status.value,
      'createdAt': bookedAt.toIso8601String(),
      'bookedAt': bookedAt.toIso8601String(),
      'notes': notes,
    };
  }

  Booking copyWith({
    String? id,
    String? bookingReference,
    String? userId,
    String? eventId,
    Event? event,
    int? ticketsCount,
    double? unitPrice,
    double? totalPrice,
    BookingStatus? status,
    DateTime? bookedAt,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingReference: bookingReference ?? this.bookingReference,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      event: event ?? this.event,
      ticketsCount: ticketsCount ?? this.ticketsCount,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
      notes: notes ?? this.notes,
    );
  }
}
