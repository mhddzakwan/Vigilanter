import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/provider/laporan_provider.dart';
import 'package:vigilanter_flutter/widgets/laporan_list.dart';
import '../theme/app_colors.dart';

class RiwayatLaporan extends StatefulWidget {
  const RiwayatLaporan({super.key});

  @override
  _RiwayatLaporanScreenState createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporan> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      context.read<LaporanProvider>().listenLaporan(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();

    final size = MediaQuery.of(context).size;
    final paddingHorizontal = size.width * 0.05;
    final paddingVertical = size.height * 0.02;
    final titleFontSize = size.width * 0.08;

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Laporan\nAnda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: paddingVertical * 2),

              // LIST DARI PROVIDER
              Expanded(
                child: (provider.laporanTerkirim.isEmpty &&
                        provider.laporanSelesai.isEmpty)
                    ? const Center(
                        child: Text(
                          "Belum ada riwayat laporan",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : LaporanList(
                        laporanTerkirim: provider.laporanTerkirim,
                        laporanSelesai: provider.laporanSelesai,
                        onHapusTerkirim: (index) =>
                            provider.batalkan(index),
                        onHapusSelesai: (index) =>
                            provider.hapus(index, false),
                        paddingVertical: 12,
                        sectionTitleSize: 18,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
