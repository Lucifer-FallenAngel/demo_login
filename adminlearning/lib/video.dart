import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoPage extends StatefulWidget {
  final String className;
  const VideoPage({super.key, required this.className});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  List videos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/video/class/${widget.className}"),
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      setState(() {
        videos = data["videos"];
        loading = false;
      });
    } else {
      loading = false;
    }
  }

  Future<void> deleteVideo(String id) async {
    await http.delete(Uri.parse("$baseUrl/api/video/$id"));
    fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
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
                return Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        "$baseUrl${v["thumbnail_path"]}",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      v["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      v["description"] ?? "",
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => deleteVideo(v["id"].toString()),
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
