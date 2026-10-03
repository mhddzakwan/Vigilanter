import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vigilanter_flutter/state/upload_laporan_state.dart';
import 'firebase_service.dart';
import 'location_service.dart';
import 'package:intl/intl.dart';
import 'package:media_store_plus/media_store_plus.dart';

class LaporanService {
  final FirebaseService _firebase = FirebaseService();
  final LocationService _location = LocationService();
  final MediaStore _mediaStore = MediaStore();

  Future<bool> kirimLaporan({
    required String userId,
    required String namaKejahatan,
    required String deskripsi,
    required String jenisLaporan,
    required String videoRealPath,
    required BuildContext context,
    required UploadLaporanState uploadState,
  }) async {
    try {
      _showLoading(context);

      // 1. Ambil lokasi lengkap
      final locationData = await _location.getCompleteLocation();
      if (locationData == null) {
        _close(context);
        _showError(context, "Tidak dapat mengambil lokasi");
        return false;
      }

      // 2. Cek file video
      final file = await _resolveToFile(videoRealPath);
      if (!await file.exists()) {
        _close(context);
        _showError(context, "File video tidak ditemukan");
        return false;
      }
      
      uploadState.start();

      final videoUrl = await _firebase.uploadVideoWithProgress(
        file,
        userId,
        uploadState,
      );

      if (videoUrl == null) {
        uploadState.error("Upload video gagal");
        return false;
      }

      // 4. Format waktu
      final formattedWaktu = getFormattedTime(DateTime.now());

      // 5. Kirim laporan ke Firestore            
      try {
        debugPrint("Mulai mengirim laporan..."); 

        final success = await _firebase.sendLaporan(
          userId: userId,
          namaKejahatan: namaKejahatan,
          deskripsi: deskripsi,
          jenisLaporan: jenisLaporan,
          videoPath: videoUrl,
          videoRealPath: videoRealPath,
          latitude: locationData['latitude'],
          longitude: locationData['longitude'],
          tempat: locationData['tempat'],
          waktuFormatted: formattedWaktu,
        );

        debugPrint("Selesai sendLaporan, hasil: $success"); 

        if (success) {
          // Update State UI
          uploadState.success();
          return true;
        } else {
          debugPrint("Laporan gagal (return false)");
          uploadState.error("Gagal mengirim laporan (Server menolak)");
          return false;
        }

      } catch (e) {
        // Ini akan menangkap jika ada crash di dalam sendLaporan
        debugPrint("ERROR CRASH: $e");
        uploadState.error("Terjadi kesalahan: $e");
        return false;
      }

    } catch (e) {
      uploadState.error("Terjadi kesalahan: $e");
      return false;
    }
  }

  /// Format waktu → “Sabtu, 30 Agustus 2025 (14:32:46 WIB)”  
  String getFormattedTime(DateTime dt) {
    final formatter = DateFormat("EEEE, d MMMM y (HH:mm:ss 'WIB')", "id_ID");
    return formatter.format(dt);
  }

  Future<File> _resolveToFile(String uriOrPath) async {
    if (uriOrPath.startsWith("content://")) {
      try {
        final resolved = await _mediaStore.getFilePathFromUri(uriString: uriOrPath);
        if (resolved != null && resolved.isNotEmpty) {
          return File(resolved);
        }
      } catch (e) {}
      throw Exception("Tidak bisa membaca content URI.");
    } else {
      return File(uriOrPath);
    }
  }

  // UI helpers
  void _showLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _close(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  // void _showSuccess(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text("Laporan berhasil dikirim!"),
  //       backgroundColor: Colors.green,
  //       behavior: SnackBarBehavior.floating,
  //       margin: const EdgeInsets.only(
  //         bottom: 70, // Naikkan snackBar agar tidak tertutup bottom nav
  //         left: 16,
  //         right: 16,
  //       ),
  //     ),
  //   );
  // }
  
  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 70, 
          left: 16,
          right: 16,
        ),
      ),
    );
  }

}
