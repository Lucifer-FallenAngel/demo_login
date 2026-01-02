import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learning/student_home.dart';

import 'create_student.dart';
import 'parent_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isStudent = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  final String baseUrl = "http://10.0.2.2:3000";

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showError("Please enter email and password");
      return;
    }

    setState(() => loading = true);

    final url = isStudent
        ? "$baseUrl/api/auth/student-login"
        : "$baseUrl/api/auth/parent-login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data is Map &&
          data["success"] == true) {
        if (isStudent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentHomePage(student: data["student"]),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ParentDashboard(parentData: data["parent"]),
            ),
          );
        }
      } else {
        _showError(data["message"] ?? "Login failed");
      }
    } catch (e) {
      _showError("Unable to connect to server");
    }

    setState(() => loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF120F25),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isStudent
                  ? "Images/Login/Student_bg.png"
                  : "Images/Login/Parent_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                  child: _buildToggle(),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          isStudent
                              ? "Images/Login/Student.png"
                              : "Images/Login/Parent.png",
                          height: 480,
                        ),
                      ),

                      Positioned.fill(
                        top: screenHeight * 0.34,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _loginCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _inputField(
            icon: Icons.email,
            hint: "Email",
            controller: emailController,
          ),
          const SizedBox(height: 16),
          _inputField(
            icon: Icons.lock,
            hint: "Password",
            controller: passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: loading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: isStudent
                    ? Colors.cyanAccent
                    : Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      isStudent ? "Login as Student" : "Login as Parent",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("New here? ", style: TextStyle(color: Colors.white70)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateStudentPage(),
                    ),
                  );
                },
                child: const Text(
                  "Create account",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: isStudent ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.42,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: isStudent
                    ? Colors.cyan.withOpacity(0.4)
                    : Colors.deepPurple.withOpacity(0.45),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isStudent = true),
                  child: const Center(
                    child: Text(
                      "Student",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isStudent = false),
                  child: const Center(
                    child: Text(
                      "Parent",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
