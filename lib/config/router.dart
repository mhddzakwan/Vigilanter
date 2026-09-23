import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/models/laporan_model.dart';
import 'package:vigilanter_flutter/provider/app_state_provider.dart';
import 'package:vigilanter_flutter/screens/detail_laporan_screen.dart';
import 'package:vigilanter_flutter/screens/notifikasi_screen.dart';
import 'package:vigilanter_flutter/screens/video_player_screen.dart';
import 'package:vigilanter_flutter/screens/video_record_screen.dart';

import '../screens/account_screen.dart';
import '../screens/isi_laporan_screen.dart';
import '../screens/splash.dart';
import '../screens/signin.dart';
import '../screens/register.dart';
import '../screens/deskripsi_laporan_screen.dart';
import '../screens/riwayat_laporan_screen.dart';
import '../screens/setting_screen.dart';
import '../screens/home_screen.dart';
import '../screens/peta_screen.dart';
import '../widgets/main_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const signin = '/signin';
  static const register = '/register';
  static const deskripsiLaporan = '/deskripsi_laporan';
  static const riwayatLaporan = '/riwayat_laporan';
  static const setting = '/setting';
  static const akun = '/akun';
  static const home = '/home';
  static const peta = '/peta';
  static const notifikasi = '/notifikasi';
  static const isilaporan = '/isilaporan';
  static const rekamVideo = '/rekam_video';
  static const videoPlayer = '/video_player';
  static const detailLaporan = '/detail_laporan';
}


GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext? context, GoRouterState state) {
      if (context == null) return null;

      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      final ingatSaya = appStateProvider.StatusIngatSaya;
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.signin ||
          state.matchedLocation == AppRoutes.register;

      if (ingatSaya && isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.signin;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    refreshListenable: AuthStateNotifier(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Splash(),
      ),
      GoRoute(
        path: AppRoutes.signin,
        builder: (context, state) => const Signin(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const Register(),
      ),
      GoRoute(
        path: AppRoutes.setting,
        builder: (context, state) => const SettingScreen(),
      ),
      GoRoute(
        path: AppRoutes.akun,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.deskripsiLaporan,
        builder: (context, state) {
          final laporan = state.extra as LaporanModel;
          return DetailLaporan(laporan: laporan);
        },
      ),
      GoRoute(
        path: AppRoutes.notifikasi,
        builder: (context, state) => const NotifikasiScreen(),
      ),
      GoRoute(
        path: AppRoutes.isilaporan,
        builder: (context, state) {
          final videoPath = state.extra as String;
          return IsiLaporanScreen(videoPath: videoPath);
        },
      ),
      GoRoute(
        path: AppRoutes.rekamVideo,
        builder: (context, state) => const VideoRecordScreen(),
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          final videoPath = state.extra as String;
          return VideoPlayerScreen(videoPath: videoPath);
        },
      ),
      GoRoute(
        path: AppRoutes.detailLaporan,
        builder: (context, state) {
          final reportId = state.extra as String;
          return DetailLaporanScreen(reportId: reportId);
        },
      ),


      // Shell dengan bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.riwayatLaporan,
                builder: (context, state) => const RiwayatLaporan(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.peta,
                builder: (context, state) {             
                  final extra = state.extra as Map<String, dynamic>?;
                  final LatLng? latLng = extra?['latLng'] as LatLng?;

                  return PetaScreen(
                    focusLatLng: latLng, 
                    focusReportId: extra?['reportId'],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

