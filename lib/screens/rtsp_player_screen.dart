import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vigilanter_flutter/services/cctv_service.dart';

class RtspPlayerScreen extends StatefulWidget {
  final String title;
  final String rtspId; // id dokumen di rtsp_streams

  const RtspPlayerScreen({
    required this.title,
    required this.rtspId,
    Key? key,
  }) : super(key: key);

  @override
  State<RtspPlayerScreen> createState() => _RtspPlayerScreenState();
}

class _RtspPlayerScreenState extends State<RtspPlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;
  final _service = CctvService();
  final List<StreamSubscription> _subs = [];
  Timer? _timeout;

  String? _currentUrl;
  bool _hasVideo = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _player = Player(
      configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn),
    );

    // Software decoding (aman untuk codec H.265 di banyak HP)
    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      ),
    );

    _subs.add(_player.stream.log.listen((log) {
      debugPrint("MPV [${log.level}] ${log.prefix}: ${log.text}");
    }));

    _subs.add(_player.stream.width.listen((w) {
      if ((w ?? 0) > 0 && mounted && !_hasVideo) {
        _timeout?.cancel();
        setState(() {
          _hasVideo = true;
          _error = null;
        });
      }
    }));

    _subs.add(_player.stream.error.listen((e) {
      debugPrint("MPV ERROR: $e");
      if (mounted && e.isNotEmpty) setState(() => _error = e);
    }));

    // REALTIME: dengarkan perubahan URL di Firestore
    _subs.add(_service.watchStreamInfo(widget.rtspId).listen(
          (info) {
        final url = info.rtspUrl;
        if (!mounted) return;

        if (url == null) {
          setState(() => _error = "Field 'url' belum diisi di Firestore.");
          return;
        }
        if (url == _currentUrl) return; // tidak ada perubahan URL

        _currentUrl = url;
        setState(() {
          _hasVideo = false;
          _error = null;
        });
        _open(url);
      },
      onError: (e) {
        if (mounted) setState(() => _error = "Gagal membaca Firestore: $e");
      },
    ));
  }

  Future<void> _open(String url) async {
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 15), () {
      if (mounted && !_hasVideo) {
        setState(() {
          _error ??= "Tidak ada gambar yang diterima dari kamera.";
        });
      }
    });

    try {
      final platform = _player.platform;
      if (platform is NativePlayer) {
        await platform.setProperty('demuxer-lavf-o', 'rtsp_transport=tcp');
      }
      await _player.open(Media(url), play: true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C3F),
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Video(controller: _videoController, controls: NoVideoControls),
              if (_error != null && !_hasVideo)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        "Gagal memutar siaran.\n$_error",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      if (_currentUrl != null)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _error = null);
                            _open(_currentUrl!);
                          },
                          child: const Text("Coba lagi"),
                        ),
                    ],
                  ),
                )
              else if (!_hasVideo)
                const CircularProgressIndicator(color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}