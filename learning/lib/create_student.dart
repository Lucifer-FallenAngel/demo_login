import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'create_parent.dart';
import 'profile_update.dart';

class CreateStudentPage extends StatefulWidget {
  const CreateStudentPage({super.key});

  @override
  State<CreateStudentPage> createState() => _CreateStudentPageState();
}

class _CreateStudentPageState extends State<CreateStudentPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _isLoading = false;

  // === IMPORTANT: This should work for Android Emulator ===
  final String baseUrl = "http://10.0.2.2:3000";

  Future<void> handleContinue() async {
    // Basic validation
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        ageCtrl.text.trim().isEmpty ||
        passCtrl.text.isEmpty ||
        confirmCtrl.text.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (passCtrl.text != confirmCtrl.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    if (passCtrl.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    final age = int.tryParse(ageCtrl.text.trim());
    if (age == null || age < 5 || age > 25) {
      _showSnackBar("Please enter a valid age (5-25)");
      return;
    }

    setState(() => _isLoading = true);

    final studentData = {
      "full_name": nameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "password": passCtrl.text,
      "age": age,
    };

    try {
      print('→ Sending request to: $baseUrl/api/auth/student-basic');
      print('→ Payload: ${jsonEncode(studentData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/student-basic'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(studentData),
          )
          .timeout(const Duration(seconds: 10));

      print('→ Status code: ${response.statusCode}');
      print('→ Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final updatedData = {...studentData, 'accountId': data['accountId']};

          if (age <= 14) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateParentPage(studentData: updatedData),
              ),
            );
          } else {
            _askParentChoice(updatedData);
          }
        } else {
          _showSnackBar(data['message'] ?? "Registration failed");
        }
      } else {
        _showSnackBar("Server responded with error: ${response.statusCode}");
      }
    } catch (e) {
      print('→ Connection error: $e');
      String errorMsg = "Cannot connect to server";

      if (e.toString().contains("Connection refused")) {
        errorMsg = "Connection refused - Is backend running on port 3000?";
      } else if (e.toString().contains("timeout")) {
        errorMsg = "Request timed out - Check if server is reachable";
      } else if (e.toString().contains("No route")) {
        errorMsg = "Wrong endpoint - Check route name";
      }

      _showSnackBar("$errorMsg\n\n$e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _askParentChoice(Map<String, dynamic> studentData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Parent Account?"),
        content: const Text(
          "Would you like to create a parent account to monitor your progress?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileUpdatePage(studentData: studentData),
                ),
              );
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateParentPage(studentData: studentData),
                ),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
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
        title: const Text("Student Signup"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create your student account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please fill in your details below",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              field("Full Name", nameCtrl),
              field("Email ID", emailCtrl, type: TextInputType.emailAddress),
              field("Age", ageCtrl, type: TextInputType.number),
              field("Create Password", passCtrl, obscure: true),
              field("Confirm Password", confirmCtrl, obscure: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : handleContinue,
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
                          "Continue",
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
    nameCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}
