class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String phone;
  final String role;
  final List<String> interests;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.phone = '',
    this.role = 'Attendee',
    this.interests = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawInterests = json['interests'];
    List<String> parsedInterests = [];
    if (rawInterests is List) {
      parsedInterests = rawInterests.map((e) => e.toString()).toList();
    }

    final id = json['_id'] as String? ?? json['id'] as String? ?? '';
    final name = json['name'] as String? ?? 'Anonymous';
    final email = json['email'] as String? ?? '';

    // Generate a default avatar URL if missing
    final avatar = json['avatarUrl'] as String? ??
        'https://api.dicebear.com/7.x/bottts/png?seed=${Uri.encodeComponent(name)}';

    return User(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatar,
      phone: json['phone'] as String? ?? '+91 98765 43210',
      role: json['role'] as String? ?? (parsedInterests.isNotEmpty ? parsedInterests.first : 'Attendee'),
      interests: parsedInterests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'role': role,
      'interests': interests,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    String? role,
    List<String>? interests,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      interests: interests ?? this.interests,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
