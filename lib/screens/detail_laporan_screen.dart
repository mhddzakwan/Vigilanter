import 'package:flutter/material.dart';
import 'package:vigilanter_flutter/screens/detail_laporan_view.dart';
import 'package:vigilanter_flutter/services/firebase_service.dart';

class DetailLaporanScreen extends StatelessWidget {
  final String reportId;
  const DetailLaporanScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return StreamBuilder(
      stream: service.streamById(reportId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Gagal memuat laporan")),
          );
        }

        return DetailLaporanView(laporan: snapshot.data!);
      },
    );
  }
}
