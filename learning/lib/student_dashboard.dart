import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboard({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final parent = studentData["parent"];

    return Scaffold(
      backgroundColor: const Color(0xFF120F25),
      appBar: AppBar(
        title: const Text(
          "Student Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1633),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            /// Profile Image
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                backgroundImage: studentData["profile_image"] != null
                    ? NetworkImage(
                        "http://10.0.2.2:3000/uploads/${studentData["profile_image"]}",
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            /// Student Info
            _info("Name", studentData["name"]),
            _info("Email", studentData["email"]),
            _info("Age", studentData["age"].toString()),
            _info("DOB", studentData["dob"] ?? "N/A"),

            const SizedBox(height: 25),

            Divider(color: Colors.white.withOpacity(0.4), thickness: 1),

            const SizedBox(height: 16),

            /// Parent Section
            if (parent != null) ...[
              const Text(
                "Parent Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _info("Name", parent["full_name"]),
              _info("Email", parent["email"]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
