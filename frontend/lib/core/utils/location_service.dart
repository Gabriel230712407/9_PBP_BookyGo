import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const Map<String, List<String>> _supportedDestinationAliases = {
    'Yogyakarta': [
      'yogyakarta',
      'kota yogyakarta',
      'sleman',
      'bantul',
      'kulon progo',
      'gunungkidul',
    ],
    'Jakarta': [
      'jakarta',
      'jakarta pusat',
      'jakarta barat',
      'jakarta timur',
      'jakarta utara',
      'jakarta selatan',
      'dki jakarta',
    ],
    'Bali': [
      'bali',
      'denpasar',
      'badung',
      'gianyar',
      'tabanan',
      'buleleng',
      'karangasem',
      'klungkung',
      'jembrana',
      'bangli',
    ],
    'Bandung': [
      'bandung',
      'kota bandung',
      'kabupaten bandung',
      'bandung barat',
      'cimahi',
    ],
  };

  Future<String?> getCurrentCityName() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return null;

    final place = placemarks.first;
    final candidates = [
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);

    for (final candidate in candidates) {
      final destination = _matchSupportedDestination(candidate);
      if (destination != null) return destination;
    }

    return null;
  }

  String? _matchSupportedDestination(String locationName) {
    final normalizedLocation = locationName.toLowerCase();

    for (final entry in _supportedDestinationAliases.entries) {
      final hasMatch = entry.value.any(normalizedLocation.contains);
      if (hasMatch) return entry.key;
    }

    return null;
  }
}