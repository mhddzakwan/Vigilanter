import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vigilanter_flutter/config/router.dart';
import 'package:vigilanter_flutter/models/laporan_model.dart';
import 'package:vigilanter_flutter/widgets/report_card.dart';

class LaporanList extends StatelessWidget {
  final List<LaporanModel> laporanTerkirim;
  final List<LaporanModel> laporanSelesai;
  final Function(int) onHapusTerkirim;
  final Function(int) onHapusSelesai;
  final double paddingVertical;
  final double sectionTitleSize;

  const LaporanList({
    required this.laporanTerkirim,
    required this.laporanSelesai,
    required this.onHapusTerkirim,
    required this.onHapusSelesai,
    required this.paddingVertical,
    required this.sectionTitleSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardFontSizeTitle = size.width * 0.04;
    final cardFontSizeSub = size.width * 0.028;
    final cardPadding = size.width * 0.04;
    final iconSize = size.width * 0.05;

    return ListView(
      children: [
        // TERKIRIM
        SectionHeader(title: 'Terkirim', fontSize: sectionTitleSize),
        SizedBox(height: paddingVertical),

        ...laporanTerkirim.asMap().entries.map((entry) {
          int index = entry.key;
          LaporanModel laporan = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: paddingVertical * 1.5),
            child: ReportCard(
              laporan: laporan,
              cardPadding: cardPadding,
              iconSize: iconSize,
              titleFontSize: cardFontSizeTitle,
              subFontSize: cardFontSizeSub,
              showBatalkan: true,
              onBatalkan: () async {
                final confirm = await _showKonfirmasi(
                  context,
                  title: "Batalkan Laporan",
                  message: "Apakah Anda yakin ingin membatalkan laporan ini?",
                  confirmText: "Batalkan",
                );
              
                if (confirm == true) onHapusTerkirim(index);
              },
              onTap: () {
                debugPrint("Reportcard clicked");
                context.push(
                  AppRoutes.deskripsiLaporan,
                  extra: laporan,
                );
              }
            ),
          );
        }),

        SizedBox(height: paddingVertical * 2),

        // SELESAI
        SectionHeader(title: 'Selesai', fontSize: sectionTitleSize),
        SizedBox(height: paddingVertical),

        ...laporanSelesai.asMap().entries.map((entry) {
          int index = entry.key;
          LaporanModel laporan = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: paddingVertical * 1.5),
            child: ReportCard(
              laporan: laporan,
              cardPadding: cardPadding,
              iconSize: iconSize,
              titleFontSize: cardFontSizeTitle,
              subFontSize: cardFontSizeSub,
              showBatalkan: false,
              onHapus: () async {
                final confirm = await _showKonfirmasi(
                  context,
                  title: "Hapus Laporan",
                  message: "Laporan akan dihapus permanen.\nAnda yakin?",
                  confirmText: "Hapus",
                  isDestructive: true,
                );

                if (confirm == true) onHapusSelesai(index);
              },
              onTap: () {
                debugPrint("Reportcard clicked");
                context.push(
                  AppRoutes.deskripsiLaporan,
                  extra: laporan,
                );
              }
            ),
          );
        }),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  const SectionHeader({required this.title, required this.fontSize, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              //fontWeight: FontWeight.w600,
              fontSize: fontSize),
        ),
        const Spacer(),
        const Icon(
          Icons.sort,
          color: Colors.white54,
          size: 20,
        ),
      ],
    );
  }
}

Future<bool?> _showKonfirmasi(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Batal"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
