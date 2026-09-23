import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppNavigator {
  static late GoRouter router;

  static void toMap({
    required LatLng latLng,
    String? reportId,
  }) {
    router.go(
      '/peta',
      extra: {
        'latLng': latLng,
        'reportId': reportId,
      },
    );
  }

  static void toDetail(String reportId) {
    router.push('/detail_laporan', extra: reportId);
  }
}
