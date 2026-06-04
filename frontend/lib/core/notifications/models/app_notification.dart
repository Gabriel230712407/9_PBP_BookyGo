import 'dart:convert';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.data,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String,
      isRead: (json['isRead'] as bool?) ?? false,
      data: json['data'] != null  // ← tambah ini
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  factory AppNotification.fromStorageValue(String raw) {
    return AppNotification.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
      'isRead': isRead,
      'data': data,
    };
  }

  String toStorageValue() => jsonEncode(toJson());

  AppNotification copyWith({
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      type: type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}
