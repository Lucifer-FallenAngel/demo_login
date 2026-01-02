import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final int accountId;

  const ProfilePage({super.key, required this.accountId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String baseUrl = "http://10.0.2.2:3000";

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/admin/account/${widget.accountId}"),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        setState(() {
          profile = data["profile"];
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (_) {
      loading = false;
    }
  }

  Widget row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B163F),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profile?["student_profile_pic"] != null
                        ? NetworkImage(
                            "$baseUrl${profile!["student_profile_pic"]}",
                          )
                        : null,
                    child: profile?["student_profile_pic"] == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),

                  const SizedBox(height: 20),

                  row("Parents Full Name", profile?["parent_name"]),
                  row("Parents Email ID", profile?["parent_email"]),
                  row("Student Full Name", profile?["student_full_name"]),
                  row("Student Email", profile?["student_email"]),
                  row("Date of Birth", profile?["student_dob"]),
                  row("Class", profile?["studying"]),
                  row("Name of the School", profile?["school_name"]),
                  row("Address of the School", profile?["school_address"]),
                  row("Home Address", profile?["student_address"]),
                  row("School Website", profile?["school_website"]),
                ],
              ),
            ),
    );
  }
}
