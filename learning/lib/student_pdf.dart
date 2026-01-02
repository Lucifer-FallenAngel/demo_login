import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class StudentPdfPage extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentPdfPage({super.key, required this.student});

  @override
  State<StudentPdfPage> createState() => _StudentPdfPageState();
}

class _StudentPdfPageState extends State<StudentPdfPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  bool loading = true;
  String errorMessage = "";
  List pdfs = [];

  @override
  void initState() {
    super.initState();
    fetchPdfs();
  }

  Future<void> fetchPdfs() async {
    try {
      // Get the full class string (e.g., "9th class" or "10th class")
      final rawClass = widget.student["studying"];

      if (rawClass == null || rawClass.toString().isEmpty) {
        setState(() {
          loading = false;
          errorMessage = "Student class not assigned";
        });
        return;
      }

      // Encode the string (e.g., "9th class" becomes "9th%20class") to handle spaces
      final classQuery = Uri.encodeComponent(rawClass.toString());
      final url = "$baseUrl/api/pdf/class/$classQuery";

      debugPrint("📘 Fetching PDFs from: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        setState(() {
          loading = false;
          errorMessage = "Server error (${response.statusCode})";
        });
        return;
      }

      final data = jsonDecode(response.body);

      if (data is Map && data["success"] == true && data["pdfs"] is List) {
        setState(() {
          pdfs = data["pdfs"];
          loading = false;
        });
      } else {
        setState(() {
          pdfs = [];
          loading = false;
          errorMessage = "No PDFs available for your class";
        });
      }
    } catch (e) {
      debugPrint("❌ PDF FETCH ERROR: $e");
      setState(() {
        loading = false;
        errorMessage = "Unable to load PDFs";
      });
    }
  }

  Future<void> openPdf(Map pdf) async {
    final pdfPath = pdf["pdf_path"];

    if (pdfPath == null) return;

    final pdfUrl = "$baseUrl$pdfPath";
    // Track view (non-blocking)
    try {
      await http.post(
        Uri.parse(
          "$baseUrl/api/student/pdf-view",
        ), // Updated to match your route
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": widget.student["id"],
          "pdf_id": pdf["id"],
        }),
      );
    } catch (_) {}

    final uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B102D),
      appBar: AppBar(
        title: const Text("PDF's"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pdfs.isEmpty
          ? Center(
              child: Text(
                errorMessage.isEmpty
                    ? "No PDFs available for your class"
                    : errorMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemCount: pdfs.length,
              itemBuilder: (_, i) {
                final pdf = pdfs[i];

                return GestureDetector(
                  onTap: () => openPdf(pdf),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: pdf["thumbnail_path"] != null
                              ? Image.network(
                                  "$baseUrl${pdf["thumbnail_path"]}",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => _placeholder(),
                                )
                              : _placeholder(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pdf["title"] ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.download, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: const Icon(Icons.picture_as_pdf, color: Colors.white70, size: 42),
    );
  }
}
