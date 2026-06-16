import 'package:flutter/services.dart';

import '../constants/api_config.dart';

class ImagePathResolver {
  ImagePathResolver._();

  static Set<String>? _assetPaths;

  static Future<List<String>> filterExistingPaths(List<String> paths) async {
    final assetPaths = await _loadAssetPaths();
    final validPaths = <String>[];

    for (final rawPath in paths) {
      final path = rawPath.trim();
      if (path.isEmpty) {
        continue;
      }

      if (isRemotePath(path) || _isStoragePath(path) || assetPaths.contains(path)) {
        validPaths.add(path);
      }
    }

    return validPaths;
  }

  static bool isRemotePath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  static String toDisplayUrl(String path) {
    final cleanPath = path.trim().replaceAll(r'\/', '/');

    if (isRemotePath(cleanPath)) {
      return cleanPath;
    }

    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api$'), '');

    if (cleanPath.startsWith('/storage/')) {
      return '$baseUrl$cleanPath';
    }

    if (cleanPath.startsWith('storage/')) {
      return '$baseUrl/$cleanPath';
    }

    if (isPublicDiskPath(cleanPath)) {
      return '$baseUrl/storage/$cleanPath';
    }

    return cleanPath;
  }

  static bool isPublicDiskPath(String path) {
    final cleanPath = path.trim().replaceAll(r'\/', '/');

    return cleanPath.startsWith('reviews/') ||
        cleanPath.startsWith('profile_photos/') ||
        cleanPath.startsWith('foto_hotels/') ||
        cleanPath.startsWith('foto_kamars/');
  }

  static bool _isStoragePath(String path) {
    return path.startsWith('storage/') ||
        path.startsWith('/storage/') ||
        isPublicDiskPath(path);
  }

  static Future<Set<String>> _loadAssetPaths() async {
    if (_assetPaths != null) {
      return _assetPaths!;
    }

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _assetPaths = manifest.listAssets().toSet();
    return _assetPaths!;
  }
}
