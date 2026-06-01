class ReviewModel {
  final int? id;
  final int? pemesananId;
  final int? kamarId;
  final int? userId;
  final int? hotelId;
  final double rating;
  final String? komentar;
  final String? createdAt;
  final String? updatedAt;

  ReviewModel({
    this.id,
    this.pemesananId,
    this.kamarId,
    this.userId,
    this.hotelId,
    required this.rating,
    this.komentar,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _toInt(json['id']),
      pemesananId: _toInt(json['pemesanan_id']),
      kamarId: _toInt(json['kamar_id']),
      userId: _toInt(json['user_id']),
      hotelId: _toInt(json['hotel_id']),
      rating: _toDouble(json['rating']) ?? 0.0,
      komentar: json['komentar']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pemesanan_id': pemesananId,
      'kamar_id': kamarId,
      'user_id': userId,
      'hotel_id': hotelId,
      'rating': rating,
      'komentar': komentar,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) return int.tryParse(value);

    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is String) return double.tryParse(value);

    return null;
  }
}