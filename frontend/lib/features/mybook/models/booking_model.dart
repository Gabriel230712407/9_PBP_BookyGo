import 'dart:convert';

import '../../room/models/room_model.dart';

class BookingModel {
  static const double taxRate = 0.1;

  BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.hotelId,
    required this.bookingCode,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.guestCount,
    required this.status,
    required this.paymentMethod,
    required this.hotelName,
    required this.hotelAddress,
    required this.roomName,
    required this.roomSmokingLabel,
    required this.hotelImage,
    required this.roomImage,
    required this.totalPrice,
    required this.createdAt,
    required this.addons,
    this.hasReview = false,
    this.reviewRating,
    this.reviewComment,
    this.reviewId,
    this.reviewPhotos,
  });

  final int id;
  final int userId;
  final int roomId;
  final int hotelId;
  final String bookingCode;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int guestCount;
  final String status;
  final String paymentMethod;
  final String hotelName;
  final String hotelAddress;
  final String roomName;
  final String roomSmokingLabel;
  final String? hotelImage;
  final String? roomImage;
  final double totalPrice;
  final DateTime? createdAt;
  final List<Addon> addons;
  bool hasReview;
  double? reviewRating;
  String? reviewComment;
  int? reviewId;
  List<String>? reviewPhotos;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final room = Map<String, dynamic>.from(json['kamar'] ?? const {});
    final hotel = Map<String, dynamic>.from(room['hotel'] ?? const {});
    final hotelPhotos = List<Map<String, dynamic>>.from(
      hotel['foto_hotels'] ?? const [],
    );
    final roomPhotos = List<Map<String, dynamic>>.from(
      room['foto_kamars'] ?? const [],
    );

    final rawPrice = _toDouble(room['harga']);
    final checkInDate = DateTime.parse(
      (json['tgl_checkin'] ?? DateTime.now().toIso8601String()).toString(),
    );
    final checkOutDate = DateTime.parse(
      (json['tgl_checkout'] ??
              checkInDate.add(const Duration(days: 1)).toIso8601String())
          .toString(),
    );

    return BookingModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      roomId: _toInt(json['kamar_id']),
      hotelId: _toInt(hotel['id']),
      bookingCode: (json['kode_booking'] ?? '').toString(),
      contactName: (json['nama'] ?? '').toString(),
      contactEmail: (json['email'] ?? '').toString(),
      contactPhone: (json['no_telp'] ?? '').toString(),
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomCount: _positiveInt(json['room_count'], fallback: 1),
      guestCount: _positiveInt(json['guest_count'], fallback: 1),
      status: (json['status_pesan'] ?? 'pending').toString(),
      paymentMethod: (json['metode_bayar'] ?? '').toString(),
      hotelName: (hotel['nama'] ?? '').toString(),
      hotelAddress: (hotel['alamat'] ?? '').toString(),
      roomName: (room['nama'] ?? '').toString(),
      roomSmokingLabel: RoomModel.fromJson(room).smokingLabel,
      hotelImage:
          hotelPhotos.isNotEmpty ? hotelPhotos.first['path'] as String? : null,
      roomImage: roomPhotos.isNotEmpty ? roomPhotos.first['path'] as String? : null,
      totalPrice: rawPrice,
      createdAt: _tryParseDate(json['created_at']),

      addons: (json['addons'] as List<dynamic>? ?? [])
          .map((e) => Addon.fromJson(e, selected: true))
          .toList(),

      hasReview: _toBool(json['has_review'] ?? json['ulasan'] != null),
      reviewRating:
          _tryDouble(json['review_rating'] ?? json['ulasan']?['rating']),
      reviewComment:
          (json['review_comment'] ?? json['ulasan']?['komentar'])?.toString(),
      reviewId: _tryInt(json['ulasan']?['id']),
      reviewPhotos: _parsePhotos(json['ulasan']?['photos']),
    );
  }

  int get totalNightCount => checkOutDate.difference(checkInDate).inDays;

  int get payableNightCount => totalNightCount <= 0 ? 1 : totalNightCount;

  double get addonsTotal =>
      addons.fold(0.0, (sum, addon) => sum + addon.price);

  double get staySubtotal => totalPrice * payableNightCount * roomCount;

  double get taxAmount => staySubtotal * taxRate;

  double get grandTotal => staySubtotal + taxAmount + addonsTotal;

  DateTime get paymentDeadline =>
      (createdAt ?? DateTime.now()).add(const Duration(minutes: 15));

  bool get isPaid => status == 'confirmed' || status == 'completed';

  bool get isPaymentPending => status == 'pending';

  bool get isExpired =>
      isPaymentPending && DateTime.now().isAfter(paymentDeadline);

  bool get isActive =>
      status != 'cancelled' &&
      status != 'completed' &&
      !checkOutDate.isBefore(DateTime.now());

  bool get canContinuePayment => isPaymentPending && !isExpired;

  String get bookingStatusLabel {
    if (isExpired) {
      return 'Expired';
    }

    if (isPaid) {
      return 'Confirmed';
    }

    if (isPaymentPending) {
      return 'Waiting payment';
    }

    return 'Active';
  }

  String get imagePath =>
      roomImage ?? hotelImage ?? 'assets/images/onboarding_bag.png';

  String get formattedTotalPrice => BookingFormatters.currency(grandTotal);

  String get formattedDateRange =>
      '${BookingFormatters.dayMonthYear(checkInDate)} - ${BookingFormatters.dayMonthYear(checkOutDate)}';

  String get formattedShortDateRange =>
      '${BookingFormatters.dayMonth(checkInDate)} - ${BookingFormatters.dayMonthYear(checkOutDate)}';

  String get stayLabel =>
      '$payableNightCount Night${payableNightCount > 1 ? 's' : ''}';

  String get roomCountLabel => '$roomCount Room${roomCount > 1 ? 's' : ''}';

  String get guestCountLabel => '$guestCount Guest${guestCount > 1 ? 's' : ''}';

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'transfer':
        return 'Transfer';
      case 'cash':
        return 'Card / Cash';
      case 'ewallet':
        return 'E-Wallet';
      default:
        return 'Select Payment';
    }
  }

  String get virtualAccountNumber {
    final suffix = (800000000000 + id * 37991).toString();
    return suffix.substring(0, 4) +
        ' ' +
        suffix.substring(4, 8) +
        ' ' +
        suffix.substring(8, 12);
  }
}

class BookingFormatters {
  BookingFormatters._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String currency(double value) {
    final number = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    var counter = 0;

    for (var i = number.length - 1; i >= 0; i--) {
      buffer.write(number[i]);
      counter++;
      if (counter % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return 'IDR ${buffer.toString().split('').reversed.join()}';
  }

  static String dayMonth(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}';
  }

  static String dayMonthYear(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

int _positiveInt(dynamic value, {required int fallback}) {
  final parsed = _toInt(value);
  return parsed > 0 ? parsed : fallback;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int? _tryInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _tryDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value is bool) return value;

  if (value is int) return value == 1;

  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }

  return false;
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

class Addon {
  final int id;
  final String name;
  final double price;
  bool selected;

  Addon({
    required this.id,
    required this.name,
    required this.price,
    this.selected = false,
  });

  factory Addon.fromJson(
    Map<String, dynamic> json, {
    bool selected = false,
  }) {
    return Addon(
      id: _toInt(json['id']),
      name: (json['nama'] ?? '').toString(),
      price: _toDouble(json['harga']),
      selected: selected,
    );
  }
}

List<String>? _parsePhotos(dynamic value) {
  if (value == null) return null;

  if (value is List) {
    return value.map((e) => e.toString().replaceAll(r'\/', '/')).toList();
  }

  if (value is String) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

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

  return null;
}
