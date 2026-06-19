import 'dart:convert';
import 'dart:io';

import '../../../core/constants/api_config.dart';
import '../../../core/utils/image_path_resolver.dart';
import '../models/hotel_model.dart';

class HotelService {
  Future<List<HotelModel>> fetchHotels() async {
    final json = await _getJson('${ApiConfig.baseUrl}/hotels');
    final List data = json['data'] ?? [];
    final hotels = data
        .map((item) => HotelModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return Future.wait(hotels.map(_resolveHotelImages));
  }

  Future<HotelModel> fetchHotelDetail(int id) async {
    final json = await _getJson('${ApiConfig.baseUrl}/hotels/$id');
    final hotel = HotelModel.fromJson(json['data'] as Map<String, dynamic>);
    return _resolveHotelImages(hotel);
  }

  Future<List<HotelModel>> searchHotels({
    required String destination,
    required int rooms,
    required int guests,
  }) async {
    final hotels = await fetchHotels();
    final kamar = hotels.where((hotel) => hotel.rooms.length >= rooms).toList();
    final keyword = destination.trim().toLowerCase();
    final priceQuery = double.tryParse(destination);

    return hotels.where((hotel) {
      final matchDestination =
          keyword.isEmpty ||
          hotel.name.toLowerCase().contains(keyword) ||
          hotel.city.toLowerCase().contains(keyword) ||
          hotel.address.toLowerCase().contains(keyword) ||
          (priceQuery != null &&
              hotel.rooms.any((room) {
                final roomPrice = double.tryParse(room.price.toString());
                return roomPrice != null && roomPrice <= priceQuery;
              }));

      final enoughRooms = hotel.rooms.length >= rooms;
      final enoughGuests = hotel.rooms.any((room) => room.capacity >= guests);

      return matchDestination && enoughRooms && enoughGuests;
    }).toList();
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(body);

      if (response.statusCode >= 400 || json['status'] != true) {
        throw Exception(json['message'] ?? 'Request failed');
      }

      return json;
    } finally {
      client.close(force: true);
    }
  }

  Future<HotelModel> _resolveHotelImages(HotelModel hotel) async {
    final validImages = await ImagePathResolver.filterExistingPaths(
      hotel.images,
    );

    return hotel.copyWith(
      image: validImages.isNotEmpty ? validImages.first : null,
      images: validImages,
    );
  }
}
