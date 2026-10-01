import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/state/upload_laporan_state.dart';
import 'package:vigilanter_flutter/theme/app_colors.dart';

class FloatingUploadStatus extends StatelessWidget {
  const FloatingUploadStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Gunakan Consumer untuk mendengarkan perubahan state
    return Consumer<UploadLaporanState>(
      builder: (context, upload, child) {
        
        // JIKA IDLE: Widget Hilang 
        if (upload.status == UploadStatus.idle) {
          return const SizedBox.shrink();
        }

        // Tentukan Warna & Konten berdasarkan status
        Color bgColor;
        Color textColor;
        String title;
        Widget content;

        if (upload.isUploading) {
          bgColor = AppColors.biruGelap; 
          textColor = Colors.white;
          title = "Mengirim laporan...";
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: upload.progress,
                color: AppColors.kuningVigilanter,
                backgroundColor: Colors.white24,
              ),
              const SizedBox(height: 6),
              Text(
                "${(upload.progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          );
        } else if (upload.isSuccess) {
          bgColor = AppColors.kuningVigilanter;
          textColor = Colors.black;
          title = "Laporan berhasil dikirim";
          content = const Row(
            children: [
              Icon(Icons.check_circle, size: 24, color: Colors.black),
              SizedBox(width: 8),
              Expanded(
                 child: Text("Terima kasih atas laporan Anda", 
                 style: TextStyle(fontSize: 12, color: Colors.black87))
              ),
            ],
          );
        } else {
          // Status Error
          bgColor = Colors.redAccent;
          textColor = Colors.white;
          title = upload.errorMessage ?? "Upload gagal";
          content = const Icon(Icons.error, size: 28, color: Colors.white);
        }

        // TAMPILKAN WIDGET
        return Positioned(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          // Bottom disesuaikan agar tidak tertutup bottom nav
          bottom: screenHeight * 0.07, 
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(16),
            color: bgColor,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Penting agar wrap content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  content,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}