import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final Map video;
  final int studentId;

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.studentId,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  late VideoPlayerController _controller;
  Timer? _timer;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isInitialized = false;
  bool _isSeeking = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _trackView();
  }

  /* ===============================
     INIT PLAYER
  ================================ */
  Future<void> _initPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse("$baseUrl${widget.video["video_path"]}"),
      );

      await _controller.initialize();
      _controller.play();

      _duration = _controller.value.duration;
      _startTimer();

      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  /* ===============================
     TIMER (ONLY WHEN NOT SEEKING)
  ================================ */
  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_controller.value.isInitialized || _isSeeking) return;

      setState(() {
        _position = _controller.value.position;
        _duration = _controller.value.duration;
      });
    });
  }

  /* ===============================
     TRACK VIEW
  ================================ */
  Future<void> _trackView() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/api/student/video-view"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": widget.studentId,
          "video_id": widget.video["id"],
        }),
      );
    } catch (_) {}
  }

  /* ===============================
     CONTROLS
  ================================ */
  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _seekToSeconds(int seconds) async {
    _isSeeking = true;

    final wasPlaying = _controller.value.isPlaying;
    if (wasPlaying) await _controller.pause();

    await _controller.seekTo(Duration(seconds: seconds));

    if (wasPlaying) await _controller.play();

    _isSeeking = false;
  }

  void _skipForward() {
    final target = _position + const Duration(seconds: 10);
    _seekToSeconds(
      target.inSeconds > _duration.inSeconds
          ? _duration.inSeconds
          : target.inSeconds,
    );
  }

  void _skipBackward() {
    final target = _position - const Duration(seconds: 10);
    _seekToSeconds(target.inSeconds < 0 ? 0 : target.inSeconds);
  }

  String _formatTime(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /* ===============================
     UI
  ================================ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B102D),
      appBar: AppBar(
        title: Text(widget.video["title"] ?? "Video"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _hasError
          ? const Center(
              child: Text(
                "Error loading video",
                style: TextStyle(color: Colors.white),
              ),
            )
          : !_isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),

                // ⏱ SEEK BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Slider(
                        activeColor: Colors.cyan,
                        inactiveColor: Colors.white24,
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        value: _position.inSeconds
                            .clamp(0, _duration.inSeconds)
                            .toDouble(),
                        onChanged: (_) {}, // disable live seek
                        onChangeEnd: (v) => _seekToSeconds(v.toInt()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(_position),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _formatTime(_duration),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ▶️ CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      color: Colors.white,
                      iconSize: 36,
                      onPressed: _skipBackward,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      color: Colors.cyan,
                      iconSize: 64,
                      onPressed: _togglePlayPause,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      color: Colors.white,
                      iconSize: 36,
                      onPressed: _skipForward,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.video["description"] ?? "No description available",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
