class RoomModel {
  final int id;
  final int hotelId;
  final String name;
  final String type;
  final String? image;
  final String facility;
  final String price;
  final String smokingPolicy;
  final String bedType;
  final int capacity;
  final double rawPrice;
  final int reviewCount;
  final List<String> images;
  final List<String> facilityList;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.type,
    required this.image,
    required this.facility,
    required this.price,
    required this.smokingPolicy,
    required this.bedType,
    required this.capacity,
    required this.rawPrice,
    required this.reviewCount,
    required this.images,
    required this.facilityList,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final fotoKamars = List<Map<String, dynamic>>.from(json['foto_kamars'] ?? []);
    fotoKamars.sort(
      (a, b) => _toInt(a['urutan']).compareTo(_toInt(b['urutan'])),
    );

    final fasilitas = List<Map<String, dynamic>>.from(json['fasilitas'] ?? []);
    final facilityNames = fasilitas
        .map((item) => (item['nama'] ?? '').toString())
        .where((item) => item.isNotEmpty)
        .toList();

    final roomImages = fotoKamars
        .map((item) => (item['path'] ?? '').toString())
        .where((item) => item.isNotEmpty)
        .toList();

    final smokingPolicy = (json['smoking_policy'] ?? 'non_smoking').toString();
    final bedType = (json['jenis_kasur'] ?? '').toString();
    final rawPrice = _toDouble(json['harga']);

    return RoomModel(
      id: _toInt(json['id']),
      hotelId: _toInt(json['hotel_id']),
      name: (json['nama'] ?? '').toString(),
      type: bedType,
      image: roomImages.isNotEmpty ? roomImages.first : null,
      facility: facilityNames.isNotEmpty
          ? facilityNames.join(' | ')
          : 'No facility information',
      price: _formatCurrency(rawPrice),
      smokingPolicy: smokingPolicy,
      bedType: bedType,
      capacity: _toInt(json['kapasitas']),
      rawPrice: rawPrice,
      reviewCount: _toInt(json['jumlah_ulasan']),
      images: roomImages,
      facilityList: facilityNames,
    );
  }

  String get smokingLabel =>
      smokingPolicy == 'smoking' ? 'Smoking Room' : 'Non-smoking Room';

  String get shortDescription {
    final details = <String>[];

    if (bedType.trim().isNotEmpty) {
      details.add(bedType.trim());
    }

    details.add(smokingLabel.toLowerCase());

    if (capacity > 0) {
      details.add('up to $capacity adults');
    }

    final facilities = facilityList.take(3).join(', ');
    final facilityText = facilities.isNotEmpty
        ? ' Featured amenities include $facilities.'
        : '';

    return '$name offers a comfortable stay with ${details.join(', ')}.$facilityText';
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

String _formatCurrency(double value) {
  final number = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  int counter = 0;

  for (int i = number.length - 1; i >= 0; i--) {
    buffer.write(number[i]);
    counter++;
    if (counter % 3 == 0 && i != 0) {
      buffer.write('.');
    }
  }

  return 'IDR ${buffer.toString().split('').reversed.join()}';
}
