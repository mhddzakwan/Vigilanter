import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/laporan_model.dart';
import '../widgets/video_player_widget.dart';
import '../theme/app_colors.dart';

class DetailLaporanView extends StatelessWidget {
  final LaporanModel laporan;
  const DetailLaporanView({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseFont = screenWidth * 0.035;

    final partWaktu = laporan.waktu.split('(');
    final tanggal = partWaktu[0].trim();
    final jam = "(${partWaktu[1].trim()}";

    final alamat = laporan.tempat.split(',');

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors.white, size: screenWidth * 0.09),
              onPressed: () => context.pop(),
            ),

            Text(
              laporan.namaKejahatan,
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            _infoRow(
              icon: Icons.location_on,
              title: "${alamat[0]}, ${alamat[1]}, ${alamat[2]}",
              subtitle: "${laporan.latitude}, ${laporan.longitude}",
              onCopy: () {
                Clipboard.setData(
                  ClipboardData(
                    text: "${laporan.latitude}, ${laporan.longitude}",
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _infoRow(
              icon: Icons.calendar_month_outlined,
              title: tanggal,
              subtitle: jam,
            ),

            const SizedBox(height: 16),

            Text(
              "Deskripsi Laporan",
              style: TextStyle(
                fontSize: baseFont * 1.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              laporan.deskripsi,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),

            const SizedBox(height: 24),

            Text(
              "Bukti Video",
              style: TextStyle(
                fontSize: baseFont * 1.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            VideoPlayerWidget(
              localPath: laporan.videoRealPath,
              url: laporan.videoDownloadUrl,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70)),
                  if (onCopy != null)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      color: Colors.white70,
                      onPressed: onCopy,
                    ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
