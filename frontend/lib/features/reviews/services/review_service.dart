import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_config.dart';

class ReviewService {
  Future<Map<String, dynamic>?> createReview(
    Map<String, dynamic> data,
    List<String> photos,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/ulasans');

    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
    });

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (final photoPath in photos) {
      final file = File(photoPath);

      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photos[]',
            photoPath,
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('CREATE REVIEW URL: $url');
    print('CREATE REVIEW DATA: $data');
    print('CREATE REVIEW PHOTOS: $photos');
    print('CREATE REVIEW STATUS: ${response.statusCode}');
    print('CREATE REVIEW BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    }

    throw Exception(response.body);
  }

  Future<Map<String, dynamic>?> updateReview(
    int reviewId,
    Map<String, dynamic> data,
    List<String> photos,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/ulasans/$reviewId');

    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
    });

    request.fields['_method'] = 'PUT';

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    final existingPhotos = <String>[];

    for (final photoPath in photos) {
      final cleanPath = photoPath.replaceAll(r'\/', '/');

      final isLocalFile = cleanPath.startsWith('/');
      final isNetworkImage = cleanPath.startsWith('http');

      if (isLocalFile) {
        final file = File(cleanPath);

        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos[]',
              cleanPath,
            ),
          );
        }
      } else if (isNetworkImage) {
        final base = ApiConfig.baseUrl.replaceAll('/api', '');
        final serverPath = cleanPath.replaceFirst('$base/storage/', '');
        existingPhotos.add(serverPath);
      } else {
        existingPhotos.add(cleanPath);
      }
    }

    request.fields['existing_photos'] = jsonEncode(existingPhotos);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('UPDATE REVIEW URL: $url');
    print('UPDATE REVIEW DATA: $data');
    print('UPDATE REVIEW EXISTING PHOTOS: $existingPhotos');
    print('UPDATE REVIEW ALL PHOTOS: $photos');
    print('UPDATE REVIEW STATUS: ${response.statusCode}');
    print('UPDATE REVIEW BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }

      return {};
    }

    throw Exception(response.body);
  }

  Future<bool> deleteReview(int reviewId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/ulasans/$reviewId');

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    print('DELETE REVIEW URL: $url');
    print('DELETE REVIEW ID: $reviewId');
    print('DELETE REVIEW STATUS: ${response.statusCode}');
    print('DELETE REVIEW BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception(response.body);
  }
}