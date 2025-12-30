import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'successful.dart';

class ParentsAccountPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ParentsAccountPage({super.key, required this.studentData});

  @override
  State<ParentsAccountPage> createState() => _ParentsAccountPageState();
}

class _ParentsAccountPageState extends State<ParentsAccountPage> {
  final parentName = TextEditingController();
  final parentEmail = TextEditingController();
  final parentPass = TextEditingController();
  final parentConfirm = TextEditingController();

  bool loading = false;

  final String baseUrl = "http://10.0.2.2:3000";

  Future<void> submit() async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("$baseUrl/api/parents/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "student_id": widget.studentData["student_id"],
        "full_name": parentName.text,
        "email": parentEmail.text,
        "password": parentPass.text,
      }),
    );

    setState(() => loading = false);

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create parent account")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A123C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text("Parent Account"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Note: Parents account is mandatory if the child is under 14.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),

            _input("Parent Full Name", parentName),
            _input("Parent Email", parentEmail),
            _input("Create Password", parentPass, isPassword: true),
            _input("Confirm Password", parentConfirm, isPassword: true),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Signup", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    TextEditingController c, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
