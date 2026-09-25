import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Ambil latitude + longitude
  Future<Position?> getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Ambil alamat lengkap
  Future<String> getCompleteAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final p = placemarks.first;

      return [
        p.street,
        p.subLocality,
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea
      ].where((e) => e != null && e.isNotEmpty).join(", ");
    } catch (e) {
      return "Lokasi tidak tersedia";
    }
  }

  /// Ambil nama jalan saja
  Future<String> getStreetNameOnly(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      return placemarks.first.street ?? "Tidak diketahui";
    } catch (e) {
      return "Tidak diketahui";
    }
  }

  /// Kembalikan semua data lokasi
  Future<Map<String, dynamic>?> getCompleteLocation() async {
    final pos = await getPosition();
    if (pos == null) return null;

    final alamat = await getCompleteAddress(pos.latitude, pos.longitude);

    return {
      "latitude": pos.latitude,
      "longitude": pos.longitude,
      "tempat": alamat,
    };
  }

  Future<String> getFormattedLocation() async {
    final pos = await getPosition();
    if (pos == null) return "Lokasi tidak tersedia";
  
    final street = await getStreetNameOnly(pos.latitude, pos.longitude);
  
    return "Lokasi Anda : $street (${pos.latitude}, ${pos.longitude})";
  }

}
