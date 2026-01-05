import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'video.dart';

class AddVideosPage extends StatefulWidget {
  const AddVideosPage({super.key});

  @override
  State<AddVideosPage> createState() => _AddVideosPageState();
}

class _AddVideosPageState extends State<AddVideosPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  final List<String> classes = [
    "1st class",
    "2nd class",
    "3rd class",
    "4th class",
    "5th class",
    "6th class",
    "7th class",
    "8th class",
    "9th class",
    "10th class",
  ];

  String? selectedClass;
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  File? thumbnail;
  File? videoFile;

  Map<String, int> classCounts = {};
  bool loading = true;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  /* ===============================
     FETCH VIDEO COUNTS
  ================================ */
  Future<void> fetchCounts() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/video/count-by-class"),
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        final Map<String, int> parsed = {};
        for (var i in data["data"]) {
          parsed[i["class_label"]] = int.parse(i["total"].toString());
        }
        setState(() => classCounts = parsed);
      }
    } catch (_) {}
    setState(() => loading = false);
  }

  /* ===============================
     PICK THUMBNAIL
  ================================ */
  Future<void> pickThumbnail() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => thumbnail = File(picked.path));
    }
  }

  /* ===============================
     PICK VIDEO
  ================================ */
  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() => videoFile = File(result.files.single.path!));
    }
  }

  /* ===============================
     UPLOAD VIDEO
  ================================ */
  Future<void> uploadVideo() async {
    if (selectedClass == null ||
        titleCtrl.text.isEmpty ||
        thumbnail == null ||
        videoFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => uploading = true);

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/video/upload"),
      );

      request.fields.addAll({
        "class_name": selectedClass!,
        "title": titleCtrl.text.trim(),
        "description": descCtrl.text.trim(),
      });

      request.files.add(
        await http.MultipartFile.fromPath("video_thumbnail", thumbnail!.path),
      );

      request.files.add(
        await http.MultipartFile.fromPath("video", videoFile!.path),
      );

      final res = await request.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        titleCtrl.clear();
        descCtrl.clear();
        selectedClass = null;
        thumbnail = null;
        videoFile = null;

        await fetchCounts();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body.isNotEmpty ? body : "Upload failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => uploading = false);
  }

  /* ===============================
     UI
  ================================ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Added"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedClass,
                          hint: const Text("Select Class"),
                          items: classes
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: uploading
                              ? null
                              : (v) => setState(() => selectedClass = v),
                        ),
                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            hintText: "Video Title",
                          ),
                        ),
                        TextField(
                          controller: descCtrl,
                          decoration: const InputDecoration(
                            hintText: "Description",
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: uploading ? null : pickThumbnail,
                          child: Text(
                            thumbnail == null
                                ? "Upload Thumbnail"
                                : "Thumbnail Selected",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: uploading ? null : pickVideo,
                          child: Text(
                            videoFile == null
                                ? "Upload Video"
                                : "Video Selected",
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: uploading ? null : uploadVideo,
                          child: uploading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Submit"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...classCounts.entries.map(
                    (e) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPage(className: e.key),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${e.key} : ${e.value}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
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
