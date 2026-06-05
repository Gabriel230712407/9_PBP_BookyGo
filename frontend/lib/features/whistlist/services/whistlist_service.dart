import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_config.dart'; // sesuaikan path-nya

class WishlistService {
  final String _baseUrl = ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Ambil semua hotel_id yang sudah di-wishlist user ini
  Future<Set<int>> getWishlistedHotelIds(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/my-wishlists'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map<int>((e) => e['hotel_id'] as int).toSet();
    }
    return {};
  }

  // Toggle wishlist (tambah/hapus sekaligus)
  // Return true kalau sekarang sudah di-wishlist, false kalau dihapus
  Future<bool> toggleWishlist(String token, int hotelId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/wishlists/toggle'),
      headers: _headers(token),
      body: jsonEncode({'hotel_id': hotelId}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body['action'] == 'added';
    }
    throw Exception('Gagal update wishlist');
  }

  // Ambil wishlist lengkap dengan data hotel
Future<List<Map<String, dynamic>>> getMyWishlists(String token) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/my-wishlists'),
    headers: _headers(token),
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body)['data'];
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}
}