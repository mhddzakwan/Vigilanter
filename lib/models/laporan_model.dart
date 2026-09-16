class LaporanModel {
  final String id;
  final String deskripsi;
  final String jenisLaporan;
  final double latitude;
  final double longitude;
  final String namaKejahatan;
  final String status;
  final String tempat;
  final String userId;
  final String videoDownloadUrl;
  final String videoRealPath;
  final String waktu;

  LaporanModel({
    required this.id,
    required this.deskripsi,
    required this.jenisLaporan,
    required this.latitude,
    required this.longitude,
    required this.namaKejahatan,
    required this.status,
    required this.tempat,
    required this.userId,
    required this.videoDownloadUrl,
    required this.videoRealPath,
    required this.waktu,
  });

  /// Hanya bisa ubah status
  LaporanModel copyWith({
    String? status,
  }) {
    return LaporanModel(
      id: id,
      deskripsi: deskripsi,
      jenisLaporan: jenisLaporan,
      latitude: latitude,
      longitude: longitude,
      namaKejahatan: namaKejahatan,
      status: status ?? this.status,
      tempat: tempat,
      userId: userId,
      videoDownloadUrl: videoDownloadUrl,
      videoRealPath: videoRealPath,
      waktu: waktu,
    );
  }

  LaporanModel copyDes({
    String? deskripsi,
  }) {
    return LaporanModel(
      id: id,
      deskripsi: deskripsi ?? this.deskripsi,
      jenisLaporan: jenisLaporan,
      latitude: latitude,
      longitude: longitude,
      namaKejahatan: namaKejahatan,
      status: status,
      tempat: tempat,
      userId: userId,
      videoDownloadUrl: videoDownloadUrl,
      videoRealPath: videoRealPath,
      waktu: waktu,
    );
  }
  LaporanModel copyNama({
    String? namaKejahatan,
  }) {
    return LaporanModel(
      id: id,
      deskripsi: deskripsi,
      jenisLaporan: jenisLaporan,
      latitude: latitude,
      longitude: longitude,
      namaKejahatan: namaKejahatan ?? this.namaKejahatan,
      status: status,
      tempat: tempat,
      userId: userId,
      videoDownloadUrl: videoDownloadUrl,
      videoRealPath: videoRealPath,
      waktu: waktu,
    );
  }

  factory LaporanModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return LaporanModel(
      id: docId,
      deskripsi: data['deskripsi'],
      jenisLaporan: data['jenis_laporan'],
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      namaKejahatan: data['nama_kejahatan'],
      status: data['status'],
      tempat: data['tempat'],
      userId: data['user_id'],
      videoDownloadUrl: data['video_download_url'],
      videoRealPath: data['video_real_path'],
      waktu : data['waktu'],
      // waktu: (data['waktu'] as Timestamp).toDate().toIso8601String(),
    );
  }
}
