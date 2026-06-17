import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String?> getCurrentCityName() async {
    // 1. Cek permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // 2. Ambil koordinat GPS
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium, // hemat baterai
    );

    // 3. Koordinat → nama kota (Nominatim/geocoding)
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return null;

    final place = placemarks.first;

    // Ambil nama kota, fallback ke subAdministrativeArea atau locality
    return place.locality?.isNotEmpty == true
        ? place.locality
        : place.subAdministrativeArea;
  }
}