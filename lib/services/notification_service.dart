import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vigilanter_flutter/screens/peta_screen.dart';
import 'package:vigilanter_flutter/services/pending_cctv_focus.dart';
import 'app_navigator.dart';

/// Menangani 2 jenis notifikasi:
///  1. Laporan kejahatan  -> data berisi latitude, longitude, report_id
///  2. Senjata terdeteksi -> data berisi type = weapon_detected, rtsp_id
class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Topic
  static const String _reportTopic = 'vigilanter_alert';
  static const String _weaponTopic = 'weapon_alerts'; // sama dengan notifier.py

  // Channel notifikasi Android
  static const AndroidNotificationChannel _reportChannel =
  AndroidNotificationChannel(
    'vigilanter',
    'Peringatan Kejahatan',
    description: 'Notifikasi laporan kejahatan valid',
    importance: Importance.max,
  );

  // ID channel ini harus sama dengan ANDROID_CHANNEL_ID di notifier.py
  static const AndroidNotificationChannel _weaponChannel =
  AndroidNotificationChannel(
    'weapon_alerts',
    'Peringatan Senjata',
    description: 'Notifikasi saat senjata terdeteksi oleh CCTV',
    importance: Importance.max,
  );

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _requestPermission();
    await _initLocalNotification();
    await _subscribeTopics();

    _setupForegroundHandler();
    _setupNotificationTapHandler();
  }

  static Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _initLocalNotification() async {
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_notification', // LOGO APP
    );

    await _localNotif.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        try {
          _handleData(Map<String, dynamic>.from(jsonDecode(payload)));
        } catch (e) {
          debugPrint('Payload notifikasi tidak valid: $e');
        }
      },
    );

    // Channel dibuat di awal supaya notifikasi FCM saat app tertutup
    // (khususnya "weapon_alerts") memakai channel prioritas tinggi.
    final android = _localNotif.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_reportChannel);
    await android?.createNotificationChannel(_weaponChannel);
  }

  static Future<void> _subscribeTopics() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _fcm.subscribeToTopic(_reportTopic);
      await _fcm.subscribeToTopic(_weaponTopic);
      debugPrint("Subscribed to $_reportTopic & $_weaponTopic");
    }
  }

  // ===================== FOREGROUND (app sedang dibuka) =====================
  static void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      final notif = message.notification;
      if (notif == null) return;

      final data = message.data;
      final isWeapon = data['type'] == 'weapon_detected';

      final channel = isWeapon ? _weaponChannel : _reportChannel;

      // Senjata: ID sama per kamera -> notifikasi baru menggantikan yang lama
      // Laporan: ID unik -> setiap laporan tampil sendiri
      final id = isWeapon
          ? (data['cam_id'] ?? 'weapon').hashCode & 0x7FFFFFFF
          : DateTime.now().millisecondsSinceEpoch ~/ 1000;

      _localNotif.show(
        id,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: const BigTextStyleInformation(''),
          ),
        ),
        payload: jsonEncode(data),
      );
    });
  }

  // ===================== TAP NOTIFIKASI =====================
  static void _setupNotificationTapHandler() async {
    // App terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // App background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static void _handleMessage(RemoteMessage message) {
    _handleData(message.data);
  }

  /// Pusat penanganan semua notifikasi yang di-tap.
  static void _handleData(Map<String, dynamic> data) {
    // 1) Senjata terdeteksi -> buka peta + pilihan RTSP / Deteksi AI
    if (data['type'] == 'weapon_detected') {
      _openCctv(data);
      return;
    }

    // 2) Laporan kejahatan -> buka peta di lokasi laporan (alur lama)
    if (!data.containsKey('latitude')) return;

    final lat = double.tryParse('${data['latitude']}');
    final lng = double.tryParse('${data['longitude']}');
    if (lat == null || lng == null) return;

    AppNavigator.toMap(
      latLng: LatLng(lat, lng),
      reportId: data['report_id'] as String?,
    );
  }

  static void _openCctv(Map<String, dynamic> data) {
    // Jangan lewati halaman login
    if (FirebaseAuth.instance.currentUser == null) return;

    final rtspId = data['rtsp_id'];
    if (rtspId is! String || rtspId.isEmpty) return;

    final lat = double.tryParse('${data['latitude']}');
    final lng = double.tryParse('${data['longitude']}');

    if (lat != null && lng != null) {
      // Jalur yang SAMA dengan notifikasi laporan (sudah teruji di semua kondisi
      // app: terbuka, background, tertutup). ID CCTV dititipkan ke PetaScreen
      // agar pilihan RTSP / Deteksi AI langsung muncul.
      PendingCctvFocus.set(rtspId);
      AppNavigator.toMap(latLng: LatLng(lat, lng), reportId: null);
    } else {
      // Cadangan: koordinat CCTV belum diisi di Firestore
      _pushWhenReady(PetaScreen(focusRtspId: rtspId));
    }
  }

  /// Saat app baru dibuka dari notifikasi, navigator bisa belum siap.
  /// Coba beberapa kali (maks. ~5 detik) sampai siap.
  static void _pushWhenReady(Widget screen, [int attempt = 0]) {
    final nav = AppNavigator.router.routerDelegate.navigatorKey.currentState;
    if (nav != null) {
      nav.push(MaterialPageRoute(builder: (_) => screen));
      return;
    }
    if (attempt < 10) {
      Future.delayed(
        const Duration(milliseconds: 500),
            () => _pushWhenReady(screen, attempt + 1),
      );
    }
  }
}