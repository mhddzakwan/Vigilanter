import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? localPath;
  final String? url;

  const VideoPlayerWidget({
    super.key,
    required this.localPath,
    required this.url,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    // PRIORITAS: content:// (video lokal dari galeri)
    if (widget.localPath != null &&
        widget.localPath!.startsWith('content://')) {
      try {
        _controller = VideoPlayerController.contentUri(
          Uri.parse(widget.localPath!),
        );
        debugPrint("Video lokal (content uri)");
      } catch (e) {
        debugPrint("Gagal buka content uri: $e");
      }
    }
  
    // FILE PATH biasa (kalau suatu saat kamu pakai path fisik)
    if (_controller == null &&
        widget.localPath != null &&
        !widget.localPath!.startsWith('content://')) {
      try {
        final file = File(widget.localPath!);
        if (await file.exists()) {
          _controller = VideoPlayerController.file(file);
          debugPrint("Video lokal (file)");
        }
      } catch (_) {}
    }
  
    // TERAKHIR: URL Firebase
    if (_controller == null && widget.url != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      debugPrint("Video firebase");
    }
  
    if (_controller == null) return;
  
    await _controller!.initialize();
  
    _chewie = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: false,
      allowPlaybackSpeedChanging: true,
      allowFullScreen: true,
    );
  
    if (mounted) setState(() {});
  }


  @override
  void dispose() {
    _chewie?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewie == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Chewie(controller: _chewie!),
    );
  }
}
