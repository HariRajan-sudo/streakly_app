class Note {
  final String id;
  final String title;
  final String content;
  final String? habitId;
  final String? habitName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.habitId,
    this.habitName,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? habitId,
    String? habitName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'habit_id': habitId,
      'habit_name': habitName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      habitId: json['habit_id'],
      habitName: json['habit_name'],
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: json['updated_at'] is String
          ? DateTime.parse(json['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
