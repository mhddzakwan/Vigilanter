import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vigilanter_flutter/config/router.dart';
import 'package:vigilanter_flutter/services/dialog_service.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/services/laporan_service.dart';
import 'package:vigilanter_flutter/services/location_service.dart';
import 'package:vigilanter_flutter/services/user_service.dart';
import 'package:vigilanter_flutter/state/upload_laporan_state.dart';
import 'package:vigilanter_flutter/widgets/floating_upload_status.dart';
import '../provider/auth_provider.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? streetName;

  final userService = UserService();
  final locationService = LocationService();
  final laporanService = LaporanService();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.userId;

    if (uid == null) return;

    // 1. Ambil nama user dari Firestore
    final name = await userService.getUserFirstName(uid);

    // 2. Ambil lokasi user
    final pos = await locationService.getPosition();
    String? street;
    if (pos != null) {
      street = await locationService.getStreetNameOnly(
          pos.latitude, pos.longitude);
    }

    setState(() {
      userName = name ?? "Pengguna";
      streetName = street ?? "Lokasi tidak diketahui";
    });

    final now = DateTime.now();
    final hasil = laporanService.getFormattedTime(now);
    debugPrint("Hasil format: $hasil");
  }
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
               children: [
                    SizedBox(height: screenHeight * 0.03),

                    // ===== Card User Info =====
                    Card(
                      color: AppColors.biruGelap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.035),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ===== Avatar + Settings (ditumpuk) =====
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Avatar user
                                Container(
                                  width: screenWidth * 0.115,
                                  height: screenWidth * 0.115,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.black,
                                      size: screenWidth * 0.095,
                                    ),
                                  ),
                                ),

                                // ===== Ikon Settings (floating di kiri bawah avatar) =====
                                Positioned(
                                  bottom: -screenWidth * 0.010,
                                  left: -screenWidth * 0.010,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push(AppRoutes.setting);
                                    },
                                    child: Container(
                                      width: screenWidth * 0.065,
                                      height: screenWidth * 0.065,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.biruGelap,
                                          width: 1.6,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.settings_rounded,
                                        size: screenWidth * 0.030,
                                        color: AppColors.biruGelap,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: screenWidth * 0.035),

                            // ===== User info =====
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: screenWidth * 0.005),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            userName ?? "Loading...",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),

                                        // Logout
                                        GestureDetector(
                                          onTap: () async {
                                            final shouldLogout = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Logout'),
                                                content: const Text('Apakah Anda yakin ingin logout?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: const Text(
                                                      'Logout',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (shouldLogout == true && context.mounted) {
                                              final authProvider = context.read<AuthProvider>();
                                              final success = await authProvider.signOut();

                                              if (!success && context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      authProvider.errorMessage ?? 'Logout gagal',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Icon(
                                            Icons.logout_rounded,
                                            color: Colors.white.withOpacity(0.9),
                                            size: screenWidth * 0.06,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight * 0.004),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                          size: screenWidth * 0.05,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Flexible(
                                          child: Text(
                                            streetName ?? "Memuat lokasi...",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w300,
                                              fontSize: screenWidth * 0.033,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ===== Notification tetap di kanan =====
                            GestureDetector(
                              onTap: () {
                                  context.push(AppRoutes.notifikasi);
                              },
                              child: Icon(
                                Icons.notifications_rounded,
                                color: Colors.white,
                                size: screenWidth * 0.075,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // ===== Greetings =====
                    Column(
                      children: [
                        Text(
                          "Halo ${userName ?? ""},",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "Butuh Laporan/Panggilan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: screenWidth * 0.065,
                          ),
                        ),
                        Text(
                          "Darurat?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: screenWidth * 0.065,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Silahkan tekan tombol berikut!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.6,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                          //     Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const VideoRecordScreen(),
                          //   ),
                          // );
                          context.push(AppRoutes.rekamVideo);
                            },
                            child: Image.asset(
                              "assets/images/tombol_lapor.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),


                    SizedBox(height: screenHeight * 0.03),

                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.6,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            splashColor: Colors.white.withOpacity(0.3),
                            onTap: () {
                              debugPrint("INKWELL TAPPED");
                              DialogService.showEmergencyPopup(context);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(
                                "assets/images/tombol_panggil.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                ],
            ),
            
            // FLOATING UPLOAD STATUS
            const FloatingUploadStatus(),
          ]
        ),
        ),
      );
  }
}
