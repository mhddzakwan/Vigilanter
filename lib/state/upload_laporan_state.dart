import 'dart:async'; // Tambahkan import ini
import 'package:flutter/material.dart';

enum UploadStatus {
  idle,
  uploading,
  success,
  error,
}

class UploadLaporanState extends ChangeNotifier {
  UploadStatus status = UploadStatus.idle;
  double progress = 0.0;
  String? errorMessage;
  
  // Variable timer untuk reset otomatis
  Timer? _resetTimer; 

  bool get isUploading => status == UploadStatus.uploading;
  bool get isSuccess => status == UploadStatus.success;
  bool get isError => status == UploadStatus.error;

  void start() {
    // Batalkan timer reset jika ada (misal user spam tombol kirim)
    _resetTimer?.cancel();
    
    status = UploadStatus.uploading;
    progress = 0;
    errorMessage = null;
    notifyListeners();
  }

  void updateProgress(double value) {
    progress = value.clamp(0, 1);
    notifyListeners();
  }

  void success() {
    status = UploadStatus.success;
    progress = 1.0;
    notifyListeners();
    
    // Panggil fungsi reset otomatis
    _startAutoReset();
  }

  void error(String msg) {
    status = UploadStatus.error;
    errorMessage = msg;
    notifyListeners();
    
    // Panggil fungsi reset otomatis
    _startAutoReset();
  }
  
  // Fungsi private untuk menghitung mundur 3 detik
  void _startAutoReset() {
    _resetTimer?.cancel(); // Pastikan tidak ada timer ganda
    _resetTimer = Timer(const Duration(seconds: 3), () {
      reset();
    });
  }

  void reset() {
    status = UploadStatus.idle;
    progress = 0;
    errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _resetTimer?.cancel(); // Bersihkan timer saat aplikasi ditutup
    super.dispose();
  }
}