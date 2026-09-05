class Event {
  final String id;
  final String name;
  final String category;
  final String description;
  final String date;
  final String time;
  final String venue;
  final int totalSeats;
  final int availableSeats;
  final double price;
  final String imageUrl;
  final bool isFeatured;
  final String organizer;
  final double rating;

  const Event({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    required this.totalSeats,
    required this.availableSeats,
    required this.price,
    required this.imageUrl,
    this.isFeatured = false,
    this.organizer = 'SnapTicket Events',
    this.rating = 4.8,
  });

  bool get isSoldOut => availableSeats <= 0;
  double get occupancyRate =>
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;

  factory Event.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] as String? ?? json['id'] as String? ?? '';
    final name = json['name'] as String? ?? 'Untitled Event';
    final category = json['category'] as String? ?? 'General';
    final description = json['description'] as String? ?? '';
    final date = json['date'] as String? ?? '';
    final time = json['time'] as String? ?? '';
    final venue = json['venue'] as String? ?? '';
    final totalSeats = (json['totalSeats'] as num?)?.toInt() ?? 100;
    final availableSeats = (json['availableSeats'] as num?)?.toInt() ?? totalSeats;
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;

    // Backend uses 'image', mock uses 'imageUrl'
    final image = json['image'] as String? ?? json['imageUrl'] as String? ?? '';

    return Event(
      id: id,
      name: name,
      category: category,
      description: description,
      date: date,
      time: time,
      venue: venue,
      totalSeats: totalSeats,
      availableSeats: availableSeats,
      price: price,
      imageUrl: image,
      isFeatured: json['isFeatured'] as bool? ?? (availableSeats < 25),
      organizer: json['organizer'] as String? ?? 'SnapTicket Official',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'date': date,
      'time': time,
      'venue': venue,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'price': price,
      'image': imageUrl,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'organizer': organizer,
      'rating': rating,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? date,
    String? time,
    String? venue,
    int? totalSeats,
    int? availableSeats,
    double? price,
    String? imageUrl,
    bool? isFeatured,
    String? organizer,
    double? rating,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      organizer: organizer ?? this.organizer,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
