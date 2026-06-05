import '../../room/models/room_model.dart';

class HotelModel {
  final int id;
  final String name;
  final String location;
  final String rating;
  final String review;
  final String? image;
  final String facilities;
  final String description;
  final String city;
  final String address;
  final double rawRating;
  final int reviewCount;
  final List<String> images;
  final List<String> facilityList;
  final List<RoomModel> rooms;
  final List<HotelReviewModel> reviews;

  HotelModel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.review,
    required this.image,
    required this.facilities,
    required this.description,
    required this.city,
    required this.address,
    required this.rawRating,
    required this.reviewCount,
    required this.images,
    required this.facilityList,
    required this.rooms,
    required this.reviews,
  });

  HotelModel copyWith({
    String? image,
    List<String>? images,
  }) {
    return HotelModel(
      id: id,
      name: name,
      location: location,
      rating: rating,
      review: review,
      image: image ?? this.image,
      facilities: facilities,
      description: description,
      city: city,
      address: address,
      rawRating: rawRating,
      reviewCount: reviewCount,
      images: images ?? this.images,
      facilityList: facilityList,
      rooms: rooms,
      reviews: reviews,
    );
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final fotoHotels = List<Map<String, dynamic>>.from(json['foto_hotels'] ?? []);
    fotoHotels.sort(
      (a, b) => _toInt(a['urutan']).compareTo(_toInt(b['urutan'])),
    );

    final fasilitas = List<Map<String, dynamic>>.from(json['fasilitas'] ?? []);
    final ulasans = List<Map<String, dynamic>>.from(json['ulasans'] ?? []);
    final kamars = List<Map<String, dynamic>>.from(json['kamars'] ?? []);

    final imagePaths = fotoHotels
        .map((item) => (item['path'] ?? '').toString())
        .where((item) => item.isNotEmpty)
        .toList();

    final facilityNames = fasilitas
        .map((item) => (item['nama'] ?? '').toString())
        .where((item) => item.isNotEmpty)
        .toList();

    final roomModels = kamars.map(RoomModel.fromJson).toList();
    final reviewModels = ulasans.map(HotelReviewModel.fromJson).toList();
    final totalReview = _toInt(json['total_review'] ?? reviewModels.length);
    final rawRating = _toDouble(json['total_rating']);

    return HotelModel(
      id: _toInt(json['id']),
      name: (json['nama'] ?? '').toString(),
      location: (json['alamat'] ?? '').toString(),
      rating: '${rawRating.toStringAsFixed(1)}/5',
      review: '$totalReview review',
      reviewCount: totalReview,
      image: imagePaths.isNotEmpty ? imagePaths.first : null,
      facilities: facilityNames.isNotEmpty
          ? facilityNames.take(3).join(', ')
          : 'No facility information',
      description: (json['alamat'] ?? '').toString(),
      city: (json['kota'] ?? '').toString(),
      address: (json['alamat'] ?? '').toString(),
      rawRating: rawRating,
      images: imagePaths,
      facilityList: facilityNames,
      rooms: roomModels,
      reviews: reviewModels,
    );
  }

  double get lowestPrice {
    if (rooms.isEmpty) return 0;
    return rooms
        .map((room) => room.rawPrice)
        .reduce((a, b) => a < b ? a : b);
  }
}

class HotelReviewModel {
  final double rating;
  final String comment;
  final String userName;

  HotelReviewModel({
    required this.rating,
    required this.comment,
    required this.userName,
  });

  factory HotelReviewModel.fromJson(Map<String, dynamic> json) {
    final user = Map<String, dynamic>.from(json['user'] ?? {});
    return HotelReviewModel(
      rating: _toDouble(json['rating']),
      comment: (json['komentar'] ?? '').toString(),
      userName: (user['name'] ?? 'Guest').toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
