import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

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
      final rawClass = widget.student["studying"];

      if (rawClass == null || rawClass.toString().isEmpty) {
        setState(() {
          loading = false;
          errorMessage = "Student class not assigned";
        });
        return;
      }

      final classQuery = Uri.encodeComponent(rawClass.toString());
      final url = "$baseUrl/api/pdf/class/$classQuery";

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

    // Track PDF view (non-blocking)
    try {
      await http.post(
        Uri.parse("$baseUrl/api/student/pdf-view"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": widget.student["id"],
          "pdf_id": pdf["id"],
        }),
      );
    } catch (_) {}

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfViewerPage(pdfUrl: pdfUrl, title: pdf["title"] ?? "PDF"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B102D),
      appBar: AppBar(
        title: const Text("PDFs"),
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
                      Text(
                        pdf["title"] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
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

/* ============================================================
   IN-APP PDF VIEWER (NO EXTERNAL APPS)
============================================================ */

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = await getTemporaryDirectory();

      final file = File(
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        localPath = file.path;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
          ? const Center(
              child: Text(
                "Failed to load PDF",
                style: TextStyle(color: Colors.white),
              ),
            )
          : PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageSnap: true,
            ),
    );
  }
}
