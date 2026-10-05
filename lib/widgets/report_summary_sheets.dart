import 'package:flutter/material.dart';
import '../models/report_summary.dart';

class ReportSummarySheet extends StatelessWidget {
  final ReportSummary data;
  final VoidCallback onDetail;

  const ReportSummarySheet({
    super.key,
    required this.data,
    required this.onDetail,
  });

  Color get dangerColor {
    switch (data.status.toLowerCase()) {
      case "diterima":
        return Colors.red;
      case "diajukan":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final scale = width < height ? width : height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.025,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1234),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(scale * 0.04),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= DRAG INDICATOR =================
          Center(
            child: Container(
              width: width * 0.08,
              height: height * 0.006,
              margin: EdgeInsets.only(bottom: height * 0.015),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(scale * 0.01),
              ),
            ),
          ),

          /// ================= JUDUL =================
          Text(
            data.namaKejahatan,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: height * 0.01),

          /// ================= LOKASI =================
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: width * 0.052,
                color: Colors.white54,
              ),
              SizedBox(width: width * 0.015),
              Expanded(
                child: Text(
                  data.tempat,
                  style: TextStyle(
                    fontSize: width * 0.03,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          /// ================= BADGE =================
          Row(
            children: [
              _badge(
                context,
                "Status",
                data.status,
                dangerColor,
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          /// ================= BUTTON =================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scale * 0.03),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.012,
                ),
              ),
              child: Text(
                "Lihat Detail Laporan",
                style: TextStyle(
                  fontSize: width * 0.034,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: height * 0.02),
        ],
      ),
    );
  }

  Widget _badge(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: width * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: width * 0.03,
        ),
      ),
    );
  }
}
