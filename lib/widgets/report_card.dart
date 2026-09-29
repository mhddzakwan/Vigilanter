import 'package:flutter/material.dart';
import 'package:vigilanter_flutter/models/laporan_model.dart';

class ReportCard extends StatelessWidget {
  final LaporanModel laporan;
  final double cardPadding;
  final double iconSize;
  final double titleFontSize;
  final double subFontSize;
  final bool showBatalkan;
  final VoidCallback? onBatalkan;
  final VoidCallback? onHapus;
  final VoidCallback? onTap;

  const ReportCard({
    required this.laporan,
    required this.cardPadding,
    required this.iconSize,
    required this.titleFontSize,
    required this.subFontSize,
    required this.showBatalkan,
    this.onBatalkan,
    this.onHapus,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = laporan.status.toLowerCase() == 'diterima'
        ? Colors.green
        : laporan.status.toLowerCase() == 'ditolak'
            ? Colors.redAccent
            : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E3B),
          borderRadius: BorderRadius.circular(iconSize * 0.3),
        ),
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report, color: Colors.white, size: iconSize * 1.1),
                SizedBox(width: cardPadding / 2),
                Expanded(
                  child: Text(
                    laporan.namaKejahatan,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: titleFontSize,
                    ),
                  ),
                ),
                if (!showBatalkan)
                  Text(
                    laporan.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: subFontSize * 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            Divider(
              color: Color(0xFFFFFFFF).withValues(alpha: 0.25),
              height: 20,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: iconSize * 0.85),
                SizedBox(width: cardPadding / 1.5),
                Expanded(
                  child: Text(
                    laporan.tempat.split(',').first,
                    style: TextStyle(color: Colors.white70, fontSize: subFontSize * 1.05),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: iconSize * 0.85),
                SizedBox(width: cardPadding / 1.5),
                Expanded(
                  child: Text(
                    laporan.waktu,
                    style: TextStyle(color: Colors.white70, fontSize: subFontSize * 1.05),
                  ),
                ),

                // BUTTON
                if (showBatalkan)
                  _btnBatalkan()
                else
                  _btnHapus()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnBatalkan() {
    return SizedBox(
      height: iconSize * 1.4,
      child: TextButton(
        onPressed: onBatalkan,
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(
              horizontal: cardPadding / 2,
              vertical: cardPadding / 6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(iconSize * 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.not_interested,
              size: subFontSize * 1.5,
              color: Colors.white,
            ),
            SizedBox(width: cardPadding * 0.4),
            Text(
              'Batalkan',
              style: TextStyle(color: Colors.white, fontSize: subFontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnHapus() {
    return SizedBox(
      height: iconSize * 1.4,
      child: TextButton(
        onPressed: onHapus,
        style: TextButton.styleFrom(
          side: BorderSide(color: Colors.white54),
          backgroundColor: Colors.white.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(
              horizontal: cardPadding / 2,
              vertical: cardPadding / 6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(iconSize * 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.delete_outline_outlined,
              size: subFontSize * 1.5,
              color: Color(0xFF000229),
            ),
            Text(
              'Hapus',
              style: TextStyle(color: Color(0xFF000229), fontSize: subFontSize),
            ),
          ],
        ),
      ),
    );
  }
}
