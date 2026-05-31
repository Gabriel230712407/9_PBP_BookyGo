import '../../room/models/room_model.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingCode,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.checkInDate,
    required this.checkOutDate,
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
  });

  final int id;
  final int userId;
  final int roomId;
  final String bookingCode;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
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
  final bool hasReview;        
  final double? reviewRating;  
  final String? reviewComment;

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
      bookingCode: (json['kode_booking'] ?? '').toString(),
      contactName: (json['nama'] ?? '').toString(),
      contactEmail: (json['email'] ?? '').toString(),
      contactPhone: (json['no_telp'] ?? '').toString(),
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      status: (json['status_pesan'] ?? 'pending').toString(),
      paymentMethod: (json['metode_bayar'] ?? '').toString(),
      hotelName: (hotel['nama'] ?? '').toString(),
      hotelAddress: (hotel['alamat'] ?? '').toString(),
      roomName: (room['nama'] ?? '').toString(),
      roomSmokingLabel: RoomModel.fromJson(room).smokingLabel,
      hotelImage: hotelPhotos.isNotEmpty ? hotelPhotos.first['path'] as String? : null,
      roomImage: roomPhotos.isNotEmpty ? roomPhotos.first['path'] as String? : null,
      totalPrice: rawPrice,
      createdAt: _tryParseDate(json['created_at']),

      addons: (json['addons'] as List<dynamic>? ?? [])
          .map((e) => Addon.fromJson(e))
          .toList(),

      hasReview: json['has_review'] ?? false,               
      reviewRating: json['review_rating']?.toDouble(),
      reviewComment: json['review_comment']?.toString(),
    );
  }

  int get totalNightCount => checkOutDate.difference(checkInDate).inDays;

  DateTime get paymentDeadline =>
      (createdAt ?? DateTime.now()).add(const Duration(minutes: 8, seconds: 40));

  bool get isPaid => status == 'confirmed' || status == 'completed';

  bool get isPaymentPending => status == 'pending';

  bool get isExpired => isPaymentPending && DateTime.now().isAfter(paymentDeadline);

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

  String get formattedTotalPrice => BookingFormatters.currency(totalPrice);

  String get formattedDateRange =>
      '${BookingFormatters.dayMonthYear(checkInDate)} - ${BookingFormatters.dayMonthYear(checkOutDate)}';

  String get formattedShortDateRange =>
      '${BookingFormatters.dayMonth(checkInDate)} - ${BookingFormatters.dayMonthYear(checkOutDate)}';

  String get stayLabel => '$totalNightCount Night${totalNightCount > 1 ? 's' : ''}';

  String get roomCountLabel => '1 Room';

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

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
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

  Addon({required this.id, required this.name, required this.price, this.selected = false});

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'],
      name: json['nama'],
      price: 60000, // harga matok per addon
      selected: false,
    );
  }
}