import 'dart:convert';

import '../../../core/constants/api_config.dart';

class ReviewModel {
  final int id;
  final int pemesananId;
  final int kamarId;
  final int userId;
  final int hotelId;
  final double rating;
  final String komentar;
  final List<String> photos;
  final String? userName;
  final String? userPhoto;
  final String? roomName;
  final String? hotelName;
  final DateTime? createdAt;

  int helpfulCount;
  bool isHelpful;

  ReviewModel({
    required this.id,
    required this.pemesananId,
    required this.kamarId,
    required this.userId,
    required this.hotelId,
    required this.rating,
    required this.komentar,
    required this.photos,
    this.userName,
    this.userPhoto,
    this.roomName,
    this.hotelName,
    this.createdAt,
    this.helpfulCount = 0,
    this.isHelpful = false,
  });

  ReviewModel copyWith({
    int? id,
    int? pemesananId,
    int? kamarId,
    int? userId,
    int? hotelId,
    double? rating,
    String? komentar,
    List<String>? photos,
    String? userName,
    String? userPhoto,
    String? roomName,
    String? hotelName,
    DateTime? createdAt,
    int? helpfulCount,
    bool? isHelpful,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      pemesananId: pemesananId ?? this.pemesananId,
      kamarId: kamarId ?? this.kamarId,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      rating: rating ?? this.rating,
      komentar: komentar ?? this.komentar,
      photos: photos ?? this.photos,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      roomName: roomName ?? this.roomName,
      hotelName: hotelName ?? this.hotelName,
      createdAt: createdAt ?? this.createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isHelpful: isHelpful ?? this.isHelpful,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    final kamar = json['kamar'] is Map<String, dynamic>
        ? json['kamar'] as Map<String, dynamic>
        : <String, dynamic>{};

    final hotel = json['hotel'] is Map<String, dynamic>
        ? json['hotel'] as Map<String, dynamic>
        : <String, dynamic>{};

    return ReviewModel(
      id: _toInt(json['id']),
      pemesananId: _toInt(json['pemesanan_id']),
      kamarId: _toInt(json['kamar_id']),
      userId: _toInt(json['user_id']),
      hotelId: _toInt(json['hotel_id']),
      rating: _toDouble(json['rating']),
      komentar: (json['komentar'] ?? '').toString(),
      photos: _parsePhotos(json['photos']),
      userName: (user['name'] ?? user['nama'] ?? 'User').toString(),
      userPhoto: user['foto']?.toString(),
      roomName: (kamar['nama'] ?? '').toString(),
      hotelName: (hotel['nama'] ?? '').toString(),
      createdAt: _tryParseDate(json['created_at']),
      helpfulCount: _toInt(json['helpful_count'] ?? json['helpfuls_count']),
      isHelpful: json['isHelpful'] == true || json['is_helpful'] == true,
    );
  }

  String get firstPhotoUrl {
    if (photos.isEmpty) return '';

    final path = photos.first.replaceAll(r'\/', '/');

    if (path.startsWith('http')) return path;

    final base = ApiConfig.baseUrl.replaceAll('/api', '');

    return '$base/storage/$path';
  }

  List<String> get photoUrls {
    final base = ApiConfig.baseUrl.replaceAll('/api', '');

    return photos.map((photo) {
      final path = photo.replaceAll(r'\/', '/');

      if (path.startsWith('http')) return path;

      return '$base/storage/$path';
    }).toList();
  }
}

class ReviewSummary {
  final double averageRating;
  final int totalReview;

  ReviewSummary({
    required this.averageRating,
    required this.totalReview,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      averageRating: _toDouble(json['average_rating']),
      totalReview: _toInt(json['total_review']),
    );
  }
}

class ReviewResponse {
  final ReviewSummary summary;
  final List<ReviewModel> reviews;

  ReviewResponse({
    required this.summary,
    required this.reviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];

    return ReviewResponse(
      summary: ReviewSummary.fromJson(
        json['summary'] ?? {
          'average_rating': 0,
          'total_review': 0,
        },
      ),
      reviews: data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

List<String> _parsePhotos(dynamic value) {
  if (value == null) return [];

  if (value is List) {
    return value.map((e) => e.toString().replaceAll(r'\/', '/')).toList();
  }

  if (value is String) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return [];

    try {
      final decoded = jsonDecode(trimmed);

      if (decoded is List) {
        return decoded
            .map((e) => e.toString().replaceAll(r'\/', '/'))
            .toList();
      }
    } catch (_) {
      return [trimmed.replaceAll(r'\/', '/')];
    }
  }

  return [];
}
