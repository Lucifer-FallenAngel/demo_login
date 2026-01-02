import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'list_account.dart';
import 'pdf_added.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  int totalAccounts = 0;
  int totalPdfs = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/admin/stats"));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() {
          totalAccounts = data["total_students"];
          totalPdfs = data["total_pdfs"];
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (_) {
      loading = false;
    }
  }

  Widget statCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Colors.cyan, Colors.blue]),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  statCard("Number of Accounts created : $totalAccounts", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ListAccountPage(),
                      ),
                    );
                  }),
                  statCard("PDF's Added : $totalPdfs", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PdfAddedPage()),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
