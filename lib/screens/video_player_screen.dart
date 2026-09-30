import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    // print("PLAYER RECEIVED PATH = ${widget.videoPath}");
    // print("FILE EXISTS = ${File(widget.videoPath).existsSync()}");

    controller = VideoPlayerController.contentUri(
      Uri.parse(widget.videoPath),
    )..initialize().then((_) {
        setState(() {});
        controller.play();
      });

    controller.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = controller.value.position >= controller.value.duration;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: controller.value.isInitialized
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),

                  // --- PLAY / PAUSE BUTTON CENTER ---
                  GestureDetector(
                    onTap: () {
                      if (isFinished) {
                        controller.seekTo(Duration.zero);
                        controller.play();
                      } else {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      }
                    },
                    child: AnimatedOpacity(
                      opacity: controller.value.isPlaying ? 0 : 1,
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            isFinished
                                ? Icons.replay
                                : controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- BOTTOM CONTROL BAR ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    color: Colors.black54,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress Slider
                        Row(
                          children: [
                            Text(
                              formatDuration(controller.value.position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: Slider(
                                activeColor: Colors.red,
                                inactiveColor: Colors.white38,
                                value: _isSeeking
                                    ? controller.value.position.inMilliseconds.toDouble()
                                    : controller.value.position.inMilliseconds.toDouble(),
                                min: 0,
                                max: controller.value.duration.inMilliseconds
                                    .toDouble(),
                                onChangeStart: (_) {
                                  _isSeeking = true;
                                },
                                onChanged: (value) {
                                  final newPos =
                                      Duration(milliseconds: value.toInt());
                                  controller.seekTo(newPos);
                                },
                                onChangeEnd: (_) {
                                  _isSeeking = false;
                                  controller.play();
                                },
                              ),
                            ),
                            Text(
                              formatDuration(controller.value.duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        // Play / Pause button (small)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 32,
                              color: Colors.white,
                              icon: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: () {
                                controller.value.isPlaying
                                    ? controller.pause()
                                    : controller.play();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}
