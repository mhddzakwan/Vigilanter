import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:vigilanter_flutter/services/cctv_service.dart';

/// Menampilkan stream hasil deteksi objek (MJPEG dari server FastAPI).
/// URL diambil REALTIME dari Firestore (field "detect_url").
class DetectionScreen extends StatefulWidget {
  final String title;
  final String rtspId; // id dokumen di rtsp_streams

  const DetectionScreen({
    required this.title,
    required this.rtspId,
    Key? key,
  }) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final _service = CctvService();
  StreamSubscription? _sub;

  String? _url;
  String? _error;
  bool _loaded = false;
  int _retry = 0; // dinaikkan untuk memaksa Mjpeg tersambung ulang

  @override
  void initState() {
    super.initState();
    _sub = _service.watchStreamInfo(widget.rtspId).listen(
          (info) {
        if (!mounted) return;
        final url = info.detectUrl;
        setState(() {
          _loaded = true;
          if (url == null) {
            _url = null;
            _error = "Field 'detect_url' belum diisi di Firestore.";
          } else if (url != _url) {
            _url = url; // URL berubah -> stream otomatis tersambung ulang
            _error = null;
          }
        });
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _loaded = true;
            _error = "Gagal membaca Firestore: $e";
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Widget _errorView(String message, {bool canRetry = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          if (canRetry) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _retry++),
              child: const Text("Coba lagi"),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (!_loaded) {
      body = const CircularProgressIndicator(color: Colors.deepOrange);
    } else if (_url == null) {
      body = _errorView(_error ?? "URL deteksi belum tersedia.");
    } else {
      body = Mjpeg(
        key: ValueKey('$_url#$_retry'),
        isLive: true,
        stream: _url!,
        fit: BoxFit.contain,
        timeout: const Duration(seconds: 10),
        loading: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
        error: (context, error, stack) => Center(
          child: _errorView(
            "Gagal terhubung ke server deteksi.\n"
                "Pastikan server FastAPI berjalan dan HP satu WiFi dengan server.",
            canRetry: true,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C3F),
        foregroundColor: Colors.white,
        title: Text("${widget.title} • Deteksi AI"),
      ),
      body: Center(child: body),
    );
  }
}