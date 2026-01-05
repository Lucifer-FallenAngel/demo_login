import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'student_pdf.dart';
import 'videos_added.dart';

class StudentHomePage extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentHomePage({super.key, required this.student});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int selectedIndex = 0;

  String get title {
    if (selectedIndex == 0) return "Students Profile";
    if (selectedIndex == 1) return "PDFs";
    return "Videos";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<int>(
            onSelected: (v) => setState(() => selectedIndex = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text("Profile")),
              PopupMenuItem(value: 1, child: Text("PDFs")),
              PopupMenuItem(value: 2, child: Text("Videos")),
            ],
          ),
        ],
      ),
      body: selectedIndex == 0
          ? StudentDashboard(studentData: widget.student)
          : selectedIndex == 1
          ? StudentPdfPage(student: widget.student)
          : StudentVideosPage(student: widget.student),
    );
  }
}
