import 'package:cloud_firestore/cloud_firestore.dart';

/// URL stream milik satu CCTV (dipakai layar RTSP & layar deteksi).
class CctvStreamInfo {
  final String? rtspUrl;   // field "url"           -> streaming RTSP langsung
  final String? detectUrl; // field "url_detection" -> stream hasil deteksi (FastAPI)

  const CctvStreamInfo({this.rtspUrl, this.detectUrl});
}

/// Titik CCTV di peta, dibaca dari Firestore.
class CctvPoint {
  final String id;     // = id dokumen = rtsp_id (mis. "rtsp_1")
  final String nama;   // mis. "CCTV Simpang Utama"
  final String tempat; // nama jalan / lokasi
  final double lat;
  final double lng;

  const CctvPoint({
    required this.id,
    required this.nama,
    required this.tempat,
    required this.lat,
    required this.lng,
  });
}

/// Struktur Firestore (satu dokumen = satu CCTV):
///   rtsp_streams/{id}
///     nama:          "CCTV Simpang Utama"                       (string)
///     tempat:        "Jl. Sisingamangaraja"                     (string)
///     latitude:      3.5675                                     (number)
///     longitude:     98.6505                                    (number)
///     url:           "rtsp://IP_KOMPUTER:8554/cam1"             (string)
///     url_detection: "http://IP_KOMPUTER:8000/stream/cam1"      (string)
class CctvService {
  final _db = FirebaseFirestore.instance;

  String? _clean(dynamic v) {
    if (v is! String) return null;
    // Buang spasi dan tanda kutip yang tidak sengaja ikut tersimpan di Firestore
    final s = v.trim().replaceAll(RegExp('^["\']+|["\']+\$'), '').trim();
    return s.isEmpty ? null : s;
  }

  double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim().replaceAll(',', '.'));
    return null;
  }

  /// REALTIME: URL satu CCTV.
  Stream<CctvStreamInfo> watchStreamInfo(String rtspId) {
    return _db.collection('rtsp_streams').doc(rtspId).snapshots().map((doc) {
      final d = doc.data();
      return CctvStreamInfo(
        rtspUrl: _clean(d?['url']),
        detectUrl: _clean(d?['url_detection']) ?? _clean(d?['detect_url']),
      );
    });
  }

  /// REALTIME: semua titik CCTV untuk marker di peta.
  /// Dokumen tanpa latitude/longitude yang valid dilewati.
  Stream<List<CctvPoint>> watchAllCctv() {
    return _db.collection('rtsp_streams').snapshots().map((snap) {
      final list = <CctvPoint>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final lat = _toDouble(d['latitude'] ?? d['lat']);
        final lng = _toDouble(d['longitude'] ?? d['lng']);
        if (lat == null || lng == null) continue;
        list.add(CctvPoint(
          id: doc.id,
          nama: _clean(d['nama']) ?? doc.id,
          tempat: _clean(d['tempat']) ?? '',
          lat: lat,
          lng: lng,
        ));
      }
      return list;
    });
  }
}