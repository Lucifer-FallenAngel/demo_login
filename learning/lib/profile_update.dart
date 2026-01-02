import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'successful.dart';

class ProfileUpdatePage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ProfileUpdatePage({super.key, required this.studentData});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  File? _selectedImage;
  bool _isLoading = false;

  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final schoolCtrl = TextEditingController();
  final schoolAddrCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();

  String? selectedClass;

  final List<String> classes = [
    "Nursery",
    "LKG",
    "UKG",
    "1st class",
    "2nd class",
    "3rd class",
    "4th class",
    "5th class",
    "6th class",
    "7th class",
    "8th class",
    "9th class",
    "10th class",
  ];

  // Change this to your real backend URL
  final String baseUrl = "http://10.0.2.2:3000"; // emulator
  // final String baseUrl = "http://your-server-ip:3000"; // real device

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dobCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitProfile() async {
    // Basic validation
    if (dobCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty ||
        selectedClass == null ||
        selectedClass!.isEmpty ||
        schoolCtrl.text.trim().isEmpty ||
        schoolAddrCtrl.text.trim().isEmpty) {
      _showSnackBar("Please fill all required fields");
      return;
    }

    final accountId = widget.studentData['accountId'];

    if (accountId == null) {
      _showSnackBar("Critical error: Account ID is missing");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/auth/complete-profile'),
      );

      // Add all text fields
      request.fields.addAll({
        'accountId': accountId.toString(),
        'dob': dobCtrl.text.trim(),
        'student_address': addressCtrl.text.trim(),
        'studying': selectedClass!,
        'school_name': schoolCtrl.text.trim(),
        'school_address': schoolAddrCtrl.text.trim(),
        'school_website': websiteCtrl.text.trim(),
      });

      // Add profile picture if selected
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile', // must match what backend expects (multer.single('profile'))
            _selectedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuccessPage()),
          );
        } else {
          _showSnackBar(data['message'] ?? "Profile update failed");
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _showSnackBar(
            errorData['message'] ?? "Server error (${response.statusCode})",
          );
        } catch (_) {
          _showSnackBar("Server error (${response.statusCode})");
        }
      }
    } catch (e) {
      _showSnackBar(
        "Failed to connect to server. Please check your connection.",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: prefix,
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
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Final Step",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Complete your profile to finish registration",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),

              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white70,
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Upload Profile Picture",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "(optional)",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 140,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Pre-filled name (disabled)
              _buildTextField(
                "Student Full Name",
                TextEditingController(
                  text:
                      widget.studentData["full_name"] ??
                      widget.studentData["name"] ??
                      "",
                ),
                enabled: false,
              ),

              const SizedBox(height: 14),

              // Date of Birth
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildTextField("Date of Birth (YYYY-MM-DD)", dobCtrl),
                ),
              ),

              const SizedBox(height: 14),

              _buildTextField("Home Address", addressCtrl),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: selectedClass,
                hint: const Text(
                  "Select Class",
                  style: TextStyle(color: Colors.white60),
                ),
                items: classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedClass = value);
                },
                dropdownColor: const Color(0xFF3A1F4A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _buildTextField("School Name", schoolCtrl),
              _buildTextField("School Address", schoolAddrCtrl),
              _buildTextField(
                "School Website (optional)",
                websiteCtrl,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
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
                          "Complete Signup",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dobCtrl.dispose();
    addressCtrl.dispose();
    schoolCtrl.dispose();
    schoolAddrCtrl.dispose();
    websiteCtrl.dispose();
    super.dispose();
  }
}
