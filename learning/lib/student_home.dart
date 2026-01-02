import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'student_pdf.dart';

class StudentHomePage extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentHomePage({super.key, required this.student});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? "Students Profile" : "PDF's"),
        actions: [
          PopupMenuButton<int>(
            onSelected: (v) => setState(() => selectedIndex = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text("Profile")),
              PopupMenuItem(value: 1, child: Text("PDF's")),
            ],
          ),
        ],
      ),
      body: selectedIndex == 0
          ? StudentDashboard(studentData: widget.student)
          : StudentPdfPage(student: widget.student),
    );
  }
}
