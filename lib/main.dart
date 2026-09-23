import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:vigilanter_flutter/config/router.dart';
import 'package:vigilanter_flutter/provider/app_state_provider.dart';
import 'package:vigilanter_flutter/provider/auth_provider.dart';
import 'package:vigilanter_flutter/provider/laporan_provider.dart';
import 'package:vigilanter_flutter/services/app_navigator.dart';
import 'package:vigilanter_flutter/services/notification_service.dart';
import 'package:vigilanter_flutter/state/upload_laporan_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load app state
  final appStateProvider = AppStateProvider();
  await appStateProvider.loadPreferences();

  // Init Firebase
  await Firebase.initializeApp();

  // Permission & MediaStore
  await _setupPermissionsAndMediaStore();

  // Format tanggal
  await initializeDateFormatting('id_ID', null);

  // Init Notification (FCM)
  await NotificationService.init();

  runApp(const App());
}

/// ================= PERMISSION =================
Future<void> _setupPermissionsAndMediaStore() async {
  if (!Platform.isAndroid) return;

  List<Permission> permissions = [Permission.storage];

  final sdk = await MediaStore().getPlatformSDKInt();
  if (sdk >= 33) {
    permissions.addAll([
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ]);
  }

  await permissions.request();

  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "Vigilanter";
}

/// ================= APP ROOT =================
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(); 
    AppNavigator.router = router;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => UploadLaporanState()),
      ],
      child: MaterialApp.router(
        title: 'Vigilanter',
        theme: ThemeData(
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
