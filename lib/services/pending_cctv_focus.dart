/// Penghubung antara notifikasi senjata dan PetaScreen.
///
/// Notifikasi membuka peta lewat AppNavigator.toMap (jalur yang sama dengan
/// notifikasi laporan). ID CCTV dititipkan di sini, lalu diambil oleh
/// PetaScreen yang baru dibuat untuk membuka pilihan RTSP / Deteksi AI.
class PendingCctvFocus {
  static String? _rtspId;
  static DateTime? _at;

  static void set(String rtspId) {
    _rtspId = rtspId;
    _at = DateTime.now();
  }

  /// Mengambil sekali pakai. Titipan yang lebih dari 15 detik dianggap basi
  /// (mencegah pilihan CCTV muncul tiba-tiba saat peta dibuka belakangan).
  static String? take() {
    final id = _rtspId;
    final at = _at;
    _rtspId = null;
    _at = null;
    if (id == null || at == null) return null;
    if (DateTime.now().difference(at).inSeconds > 15) return null;
    return id;
  }
}