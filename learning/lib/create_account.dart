import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'parents_account.dart';
import 'successful.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  File? profileImage;
  bool loading = false;

  final String baseUrl = "http://10.0.2.2:3000";

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  /// 🔥 CREATE STUDENT API CALL
  Future<int?> createStudent() async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/students/create"),
      );

      request.fields["full_name"] = nameCtrl.text;
      request.fields["email"] = emailCtrl.text;
      request.fields["dob"] = dobCtrl.text;
      request.fields["age"] = ageCtrl.text;
      request.fields["password"] = passCtrl.text;

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("profile", profileImage!.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return data["studentId"];
      } else {
        debugPrint("Error: $responseBody");
        return null;
      }
    } catch (e) {
      debugPrint("Student API error: $e");
      return null;
    }
  }

  /// 🔥 MAIN CONTINUE LOGIC
  void handleContinue() async {
    if (loading) return;

    setState(() => loading = true);

    final age = int.tryParse(ageCtrl.text) ?? 0;

    final studentId = await createStudent();

    if (studentId == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create student")));
      return;
    }

    final studentPayload = {
      "student_id": studentId,
      "full_name": nameCtrl.text,
      "email": emailCtrl.text,
    };

    if (age <= 14) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParentsAccountPage(studentData: studentPayload),
        ),
      );
    } else {
      _showParentChoiceDialog(studentPayload);
    }

    setState(() => loading = false);
  }

  void _showParentChoiceDialog(Map<String, dynamic> studentData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Parent Account?"),
        content: const Text(
          "Do you want to create a parent account for monitoring?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SuccessPage()),
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
                  builder: (_) => ParentsAccountPage(studentData: studentData),
                ),
              );
            },
            child: const Text("Yes"),
          ),
        ],
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
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.white),
            const SizedBox(height: 20),

            _input("Full Name", nameCtrl),
            _input("Email ID", emailCtrl),
            _input("Date of Birth (yyyy-mm-dd)", dobCtrl),
            _input("Age", ageCtrl, keyboard: TextInputType.number),
            _input("Create Password", passCtrl, isPassword: true),
            _input("Confirm Password", confirmCtrl, isPassword: true),

            const SizedBox(height: 15),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 55,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  profileImage == null
                      ? "Upload Profile Image"
                      : "Image Selected ✓",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Continue", style: TextStyle(fontSize: 18)),
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
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: isPassword,
        keyboardType: keyboard,
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
