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
    Map<String, dynamic>? parsedData;
    final rawData = json['data'];
    if (rawData is Map) {
      parsedData = Map<String, dynamic>.from(rawData);
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        parsedData = Map<String, dynamic>.from(
          jsonDecode(rawData) as Map,
        );
      } catch (_) {
        parsedData = null;
      }
    }

    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String,
      isRead: (json['is_read'] as bool?) ?? false,
      data: parsedData,
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
