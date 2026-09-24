import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class EmergencyPopup extends StatelessWidget {
  final VoidCallback? onClose;

  const EmergencyPopup({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.biruVigilanter,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05, bottom: screenWidth * 0.08, top: screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Tombol close =====
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose ?? () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                ),
              ),
            ),

            // ===== Lingkaran kuning dengan ikon telepon =====
            CircleAvatar(
              radius: screenWidth * 0.12,
              backgroundColor: AppColors.kuningVigilanter,
              child: Icon(
                Icons.phone_in_talk_rounded,
                color: AppColors.biruVigilanter,
                size: screenWidth * 0.12,
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            // ===== Judul =====
            Text(
              'Panggilan Darurat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),

            Text(
              'Silahkan pilih panggilan darurat dibawah ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenWidth * 0.07),

            // ===== Daftar opsi panggilan =====
            _buildEmergencyOption(
              context,
              iconPath: 'assets/images/ic_police.png',
              number: '110',
              title: 'Kepolisian',
            ),
            SizedBox(height: screenWidth * 0.04),

            _buildEmergencyOption(
              context,
              iconPath: 'assets/images/ic_ambulance.png',
              number: '118',
              title: 'Ambulans',
            ),
            SizedBox(height: screenWidth * 0.04),

            _buildEmergencyOption(
              context,
              iconPath: 'assets/images/ic_damkar.png',
              number: '113',
              title: 'Pemadam',
            ),
          ],
        ),
      ),
    );
  }

  // ===== Widget item opsi panggilan darurat =====
  Widget _buildEmergencyOption(
    BuildContext context, {
    required String iconPath,
    required String number,
    required String title,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: const Color(0xFF0D1234),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleEmergencyCall(context, number, title),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          height: screenWidth * 0.18,
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                fit: BoxFit.contain,
              ),
              SizedBox(width: screenWidth * 0.04),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.call,
                color: Colors.white,
                size: screenWidth * 0.07,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Konfirmasi sebelum panggilan =====
  void _handleEmergencyCall(BuildContext context, String number, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.biruGelap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Panggilan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghubungi $title ($number)?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makePhoneCall(number);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kuningVigilanter,
              foregroundColor: AppColors.biruVigilanter,
            ),
            child: const Text('Hubungi'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String number) {
    launchUrl(Uri.parse('tel:$number'));
  }
}
