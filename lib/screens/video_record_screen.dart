import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:vigilanter_flutter/config/router.dart';

class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({super.key});

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _cameraIndex = 0;

  bool _isRecording = false;
  bool _flashOn = false;

  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });
  }

  Future<void> _initCamera() async {
    try {
      _cameras ??= await availableCameras();

      _controller = CameraController(
        _cameras![_cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();

      // hanya panggil sekali
      if (_controller!.value.isPreviewPaused == false) {
        try {
          await _controller!.prepareForVideoRecording();
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }}

  // Flip camera
  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _cameraIndex = (_cameraIndex + 1) % _cameras!.length;

    await _controller?.dispose();
    _controller = null;
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 400));
    await _initCamera();
  }

  // Toggle flash
  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    _flashOn = !_flashOn;
    await _controller!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  // Timer
  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // Start recording
  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    await _controller!.prepareForVideoRecording(); // WAJIB agar tidak slowmo

    await _controller!.startVideoRecording();

    _isRecording = true;
    _startTimer();
    setState(() {});
  }


  // Stop and return file
  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    _stopTimer();

    // stop repository recording, get the temporary recorded file
    final XFile file = await _controller!.stopVideoRecording();
    _isRecording = false;
    setState(() {});

    try {
      // simpan file tmp ke gallery/MediaStore
      final SaveInfo? savedInfo = await _saveToGallery(file.path);

      // optional: debug
      debugPrint('SavedInfo: ${savedInfo?.toString()}');

      // kembalikan ke screen Isilaporan: kirim uri string (jika tersedia) atau path temporer
      final returnValue = savedInfo?.uri.toString() ?? file.path;
      context.go(AppRoutes.isilaporan, extra: returnValue);

    } catch (e, st) {
      debugPrint('Error saving to gallery: $e\n$st');
      // fallback: langsung kembalikan file.path jika gagal
      Navigator.pop(context, file.path);
    }
  }

  /// Simpan file sementara (tempFilePath) ke gallery lewat MediaStore plugin
  /// --> Mengembalikan SaveInfo? sesuai dokumentasi media_store_plus 0.1.3
  Future<SaveInfo?> _saveToGallery(String tempFilePath) async {
    final mediaStore = MediaStore();

    // pastikan appFolder sudah di-set di main.dart 
    // MediaStore.appFolder = "Vigilanter";

    // Pilih dirName yang sesuai. Untuk video biasanya pakai DirName.movies
    // Jika ingin masuk Movies/Vigilanter -> relativePath: "Vigilanter"
    final SaveInfo? result = await mediaStore.saveFile(
      tempFilePath: tempFilePath,     // path file rekaman sementara (XFile.path)
      dirType: DirType.video,         // tipe: video
      dirName: DirName.movies,        // gunakan DirName.movies (enum)
      relativePath: "Vigilanter",     // (opsional) folder/album di dalam Movies
    );

    debugPrint('media_store_plus.saveFile returned: $result');

    return result;
  }

  // --- AKHIR PENGGANTIAN ---


  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _controller == null || !_controller!.value.isInitialized
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
                children: [
                  // Camera Preview
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover, // memenuhi layar tapi tetap proporsional
                      child: SizedBox(
                        width: _controller!.value.previewSize!.height,
                        height: _controller!.value.previewSize!.width,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),

        
                  // Instruction Text (Top)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Colors.black.withOpacity(0.5),
                      child: const Text(
                        "Fokuskan kamera pada wajah pelaku atau plat kendaraan dengan pencahayaan yang cukup.\n"
                        "Selama merekam, sebutkan deskripsi kejadian secara langsung.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
        
                  // Timer
                  if (_isRecording)
                    Positioned(
                      top: 110,
                      left: 20,
                      child: Text(
                        _formatTime(_seconds),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
        
                  // Flash button
                  Positioned(
                    top: 120,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
        
                  // Flip camera
                  Positioned(
                    top: 180,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.cameraswitch, size: 32, color: Colors.white),
                      onPressed: _flipCamera,
                    ),
                  ),
        
                  // Bottom Record Button
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
