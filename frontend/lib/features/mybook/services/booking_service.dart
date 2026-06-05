import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/auth/services/auth_service.dart';
import '../../../core/constants/api_config.dart';
import '../models/booking_model.dart';

class BookingService {
  static const _requestTimeout = Duration(seconds: 15);

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<List<BookingModel>> fetchMyBookings() async {
    final session = await AuthService.currentSession();
    if (session == null) {
      return const [];
    }

    final response = await _get('/my-pemesanans', token: session.token);
    final decoded = _decodeJson(response.body);
    final data = List<Map<String, dynamic>>.from(decoded['data'] ?? const []);
    return data.map(BookingModel.fromJson).toList();
  }

  Future<BookingModel> fetchBookingById(int bookingId) async {
    final session = await AuthService.currentSession();
    if (session == null) {
      throw const BookingException('Please sign in first.');
    }

    final response = await _get('/pemesanans/$bookingId', token: session.token);
    final decoded = _decodeJson(response.body);
    return BookingModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<List<Addon>> fetchAddons() async {
    final response = await _getPublic('/addons');
    final decoded = _decodeJson(response.body);
    final data = List<Map<String, dynamic>>.from(decoded['data'] ?? const []);
    return data.map(Addon.fromJson).toList();
  }

  Future<BookingModel> createBooking({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
    List<int> addonIds = const [],
  }) async {
    final session = await AuthService.currentSession();
    if (session == null) {
      throw const BookingException('Please sign in first to continue booking.');
    }

    final body = <String, String>{
      'kamar_id': '$roomId',
      'tgl_checkin': _toApiDate(checkInDate),
      'tgl_checkout': _toApiDate(checkOutDate),
      'status_pesan': 'pending',
      'nama': contactName,
      'email': contactEmail,
      'no_telp': contactPhone,
    };

    for (var index = 0; index < addonIds.length; index++) {
      body['addon_ids[$index]'] = '${addonIds[index]}';
    }

    final response = await _send(
      'POST',
      '/pemesanans',
      token: session.token,
      body: body,
    );

    final decoded = _decodeJson(response.body);
    return BookingModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<BookingModel> updateBooking({
    required int bookingId,
    String? status,
    String? paymentMethod,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
  }) async {
    final session = await AuthService.currentSession();
    if (session == null) {
      throw const BookingException('Please sign in again to update this booking.');
    }

    final body = <String, String>{};
    if (status != null) body['status_pesan'] = status;
    if (paymentMethod != null) body['metode_bayar'] = paymentMethod;
    if (contactName != null) body['nama'] = contactName;
    if (contactEmail != null) body['email'] = contactEmail;
    if (contactPhone != null) body['no_telp'] = contactPhone;

    final response = await _send(
      'PUT',
      '/pemesanans/$bookingId',
      token: session.token,
      body: body,
    );

    final decoded = _decodeJson(response.body);
    return BookingModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBooking(int bookingId) async {
    final session = await AuthService.currentSession();
    if (session == null) {
      throw const BookingException('Please sign in again to delete this booking.');
    }

    await _send(
      'DELETE',
      '/pemesanans/$bookingId',
      token: session.token,
      body: null,
    );
  }

  Future<http.Response> _get(String path, {required String token}) async {
    try {
      final response = await http.get(
        _uri(path),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_requestTimeout);

      _throwIfFailed(response);
      return response;
    } on BookingException {
      rethrow;
    } on SocketException {
      throw const BookingException(
        'Cannot reach the server. Make sure Laravel is running and reachable from this device.',
      );
    } on FormatException {
      throw const BookingException('The server returned unreadable booking data.');
    } on TimeoutException {
      throw const BookingException('The booking request timed out. Please try again.');
    }
  }

  Future<http.Response> _getPublic(String path) async {
    try {
      final response = await http.get(
        _uri(path),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(_requestTimeout);

      _throwIfFailed(response);
      return response;
    } on BookingException {
      rethrow;
    } on SocketException {
      throw const BookingException(
        'Cannot reach the server. Make sure Laravel is running and reachable from this device.',
      );
    } on FormatException {
      throw const BookingException('The server returned unreadable booking data.');
    } on TimeoutException {
      throw const BookingException('The booking request timed out. Please try again.');
    }
  }

  Future<http.Response> _send(
    String method,
    String path, {
    required String token,
    required Map<String, String>? body,
  }) async {
    try {
      late http.Response response;
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      switch (method) {
        case 'POST':
          response = await http
              .post(_uri(path), headers: headers, body: body)
              .timeout(_requestTimeout);
          break;
        case 'PUT':
          response = await http
              .put(_uri(path), headers: headers, body: body)
              .timeout(_requestTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(_uri(path), headers: headers)
              .timeout(_requestTimeout);
          break;
        default:
          throw const BookingException('Unsupported request method.');
      }

      _throwIfFailed(response);
      return response;
    } on BookingException {
      rethrow;
    } on SocketException {
      throw const BookingException(
        'Cannot reach the server. Make sure Laravel is running and reachable from this device.',
      );
    } on FormatException {
      throw const BookingException('The server returned unreadable booking data.');
    } on TimeoutException {
      throw const BookingException('The booking request timed out. Please try again.');
    }
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final message = (decoded['message'] ?? 'Something went wrong while saving your booking.')
        .toString();

    if (decoded['errors'] is Map<String, dynamic>) {
      final errors = decoded['errors'] as Map<String, dynamic>;
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          throw BookingException(value.first.toString());
        }
      }
    }

    throw BookingException(message);
  }

  Map<String, dynamic> _decodeJson(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if (decoded['status'] != true) {
      throw BookingException(
        (decoded['message'] ?? 'Something went wrong while saving your booking.')
            .toString(),
      );
    }
    return decoded;
  }

  String _toApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class BookingException implements Exception {
  const BookingException(this.message);

  final String message;

  @override
  String toString() => message;
}
