import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile.dart';

class ListAccountPage extends StatefulWidget {
  const ListAccountPage({super.key});

  @override
  State<ListAccountPage> createState() => _ListAccountPageState();
}

class _ListAccountPageState extends State<ListAccountPage> {
  final String baseUrl = "http://10.0.2.2:3000";

  bool loading = true;
  List accounts = [];

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/admin/accounts"));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() {
          accounts = data["accounts"];
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (_) {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Accounts Created"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final item = accounts[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(accountId: item["id"]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.cyan,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item["student_name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.school, color: Colors.white),
                            const SizedBox(width: 10),
                            if (item["has_parent"])
                              const Icon(
                                Icons.family_restroom,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
