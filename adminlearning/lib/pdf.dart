import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PdfPage extends StatefulWidget {
  final String className;

  const PdfPage({super.key, required this.className});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  List pdfs = [];
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchPdfs();
  }

  Future<void> fetchPdfs() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/pdf/class/${widget.className}"),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() {
          pdfs = data["pdfs"];
          loading = false;
        });
      } else {
        loading = false;
        error = "Failed to load PDFs";
      }
    } catch (e) {
      loading = false;
      error = "Connection error";
    }
  }

  Future<void> openPdf(String path) async {
    final uri = Uri.parse("$baseUrl$path");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> deletePdf(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete PDF"),
        content: const Text("Are you sure you want to delete this PDF?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await http.delete(Uri.parse("$baseUrl/api/pdf/$id"));

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      fetchPdfs(); // refresh list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete PDF")));
    }
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
          : error.isNotEmpty
          ? Center(child: Text(error))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemCount: pdfs.length,
              itemBuilder: (context, i) {
                final pdf = pdfs[i];

                return Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => openPdf(pdf["pdf_path"]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            "$baseUrl${pdf["thumbnail_path"]}",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.black26,
                              child: const Icon(
                                Icons.picture_as_pdf,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      pdf["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => deletePdf(pdf["id"].toString()),
                        child: const Text("Delete"),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
