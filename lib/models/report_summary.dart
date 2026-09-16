import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportSummary {
  final String id;
  final String namaKejahatan;
  final String tempat;
  final String status;
  final String waktu;
  final LatLng posisi;

  ReportSummary({
    required this.id,
    required this.namaKejahatan,
    required this.tempat,
    required this.status,
    required this.waktu,
    required this.posisi,
  });
}
