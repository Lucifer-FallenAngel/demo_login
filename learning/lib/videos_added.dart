import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'video.dart';

class StudentVideosPage extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentVideosPage({super.key, required this.student});

  @override
  State<StudentVideosPage> createState() => _StudentVideosPageState();
}

class _StudentVideosPageState extends State<StudentVideosPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  bool loading = true;
  List videos = [];
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/student/videos/${widget.student["id"]}"),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() {
          videos = data["videos"];
          loading = false;
        });
      } else {
        setState(() {
          error = "No videos available";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Failed to load videos";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B102D),
      appBar: AppBar(
        title: const Text("Videos"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : videos.isEmpty
          ? Center(
              child: Text(error, style: const TextStyle(color: Colors.white70)),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemCount: videos.length,
              itemBuilder: (_, i) {
                final v = videos[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          studentId: widget.student["id"],
                          video: v,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            "$baseUrl${v["thumbnail_path"]}",
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        v["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
