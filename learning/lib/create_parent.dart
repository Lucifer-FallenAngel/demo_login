import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile_update.dart';

class CreateParentPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const CreateParentPage({super.key, required this.studentData});

  @override
  State<CreateParentPage> createState() => _CreateParentPageState();
}

class _CreateParentPageState extends State<CreateParentPage> {
  final parentNameCtrl = TextEditingController();
  final parentEmailCtrl = TextEditingController();
  final parentPassCtrl = TextEditingController();
  final parentConfirmCtrl = TextEditingController();

  bool _isLoading = false;

  // Change this to your actual backend URL
  final String baseUrl = "http://10.0.2.2:3000"; // for emulator
  // final String baseUrl = "http://your-server-ip:3000"; // real device

  Future<void> proceed() async {
    // Basic validation
    if (parentNameCtrl.text.trim().isEmpty ||
        parentEmailCtrl.text.trim().isEmpty ||
        parentPassCtrl.text.isEmpty ||
        parentConfirmCtrl.text.isEmpty) {
      _showSnackBar("Please fill in all parent fields");
      return;
    }

    if (parentPassCtrl.text != parentConfirmCtrl.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    if (parentPassCtrl.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    // Simple email format check (you can make it more strict if needed)
    if (!parentEmailCtrl.text.contains('@') ||
        !parentEmailCtrl.text.contains('.')) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);

    final parentData = {
      "accountId": widget.studentData['accountId'],
      "parent_name": parentNameCtrl.text.trim(),
      "parent_email": parentEmailCtrl.text.trim(),
      "parent_password": parentPassCtrl.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/parent'), // must match your route name
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(parentData),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        // Pass updated data forward (including accountId)
        final updatedData = {
          ...widget.studentData,
          "parent_name": parentData["parent_name"],
          "parent_email": parentData["parent_email"],
          // no need to pass password forward
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileUpdatePage(studentData: updatedData),
          ),
        );
      } else {
        _showSnackBar(result['message'] ?? "Failed to save parent details");
      }
    } catch (e) {
      _showSnackBar("Cannot connect to server. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget field(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A123C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Parent Signup"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Parent Account Setup",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Note: Required for students under 14 years old",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),

              field("Parent's Full Name", parentNameCtrl),
              field(
                "Parent's Email",
                parentEmailCtrl,
                type: TextInputType.emailAddress,
              ),
              field("Create Password", parentPassCtrl, obscure: true),
              field("Confirm Password", parentConfirmCtrl, obscure: true),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Continue to Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    parentNameCtrl.dispose();
    parentEmailCtrl.dispose();
    parentPassCtrl.dispose();
    parentConfirmCtrl.dispose();
    super.dispose();
  }
}
