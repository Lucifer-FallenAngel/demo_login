import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  final Map<String, dynamic> parentData;

  const ParentDashboard({super.key, required this.parentData});

  @override
  Widget build(BuildContext context) {
    final children = parentData["children"] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text("Parent Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Your Children",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...children.map(
            (child) => Card(
              child: ListTile(
                leading: const Icon(Icons.school),
                title: Text(child["name"]),
                subtitle: Text("Age: ${child["age"]}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
