import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'pdf.dart';

class PdfAddedPage extends StatefulWidget {
  const PdfAddedPage({super.key});

  @override
  State<PdfAddedPage> createState() => _PdfAddedPageState();
}

class _PdfAddedPageState extends State<PdfAddedPage> {
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
  final TextEditingController titleCtrl = TextEditingController();

  File? thumbnailFile;
  File? pdfFile;

  Map<String, int> classCounts = {};
  bool loading = true;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  /* ===============================
     FETCH COUNT PER CLASS
  =============================== */
  Future<void> fetchCounts() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/pdf/count-by-class"));

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        final Map<String, int> parsed = {};

        // Inside pdf_added.dart -> fetchCounts()
        for (var item in data["data"]) {
          // Change "class_name" to "class_label" to match your SQL table
          parsed[item["class_label"]] = int.parse(item["total"].toString());
        }

        setState(() {
          classCounts = parsed;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  /* ===============================
     PICK THUMBNAIL IMAGE
  =============================== */
  Future<void> pickThumbnail() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        thumbnailFile = File(picked.path);
      });
    }
  }

  /* ===============================
     PICK PDF FILE
  =============================== */
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfFile = File(result.files.single.path!);
      });
    }
  }

  /* ===============================
     UPLOAD PDF
  =============================== */
  Future<void> uploadPdf() async {
    if (selectedClass == null ||
        titleCtrl.text.trim().isEmpty ||
        thumbnailFile == null ||
        pdfFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => uploading = true);

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/pdf/upload"),
      );

      request.fields["class_name"] = selectedClass!;
      request.fields["title"] = titleCtrl.text.trim();

      request.files.add(
        await http.MultipartFile.fromPath("thumbnail", thumbnailFile!.path),
      );

      request.files.add(
        await http.MultipartFile.fromPath("pdf", pdfFile!.path),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body);

        if (json["success"] == true) {
          titleCtrl.clear();
          selectedClass = null;
          thumbnailFile = null;
          pdfFile = null;

          await fetchCounts();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF uploaded successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json["message"] ?? "Upload failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
    } finally {
      setState(() => uploading = false);
    }
  }

  /* ===============================
     UI
  =============================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF's Added"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ---------- ADD PDF CARD ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add PDF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: selectedClass,
                          hint: const Text("Select Class"),
                          items: classes
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedClass = v),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            hintText: "Enter PDF title",
                          ),
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: pickThumbnail,
                          child: Text(
                            thumbnailFile == null
                                ? "Upload Thumbnail"
                                : "Thumbnail Selected",
                          ),
                        ),

                        ElevatedButton(
                          onPressed: pickPdf,
                          child: Text(
                            pdfFile == null ? "Upload PDF" : "PDF Selected",
                          ),
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton(
                          onPressed: uploading ? null : uploadPdf,
                          child: uploading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Submit"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ---------- CLASS LIST ----------
                  ...classCounts.entries.map((entry) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfPage(className: entry.key),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${entry.key} : ${entry.value}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
