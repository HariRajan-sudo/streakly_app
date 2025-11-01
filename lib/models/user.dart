class AppUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;
  final bool premium;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.preferences,
    required this.premium,
  });

  bool get isPremium => premium;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'preferences': preferences,
      'premium': premium,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      preferences: json['preferences'],
      premium: json['premium'] ?? false,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    bool? premium,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      premium: premium ?? this.premium,
    );
  }
}
