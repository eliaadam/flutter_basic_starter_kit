import 'package:flutter/material.dart';

class ProjectAnalyticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> userProjects;

  const ProjectAnalyticsScreen({super.key, required this.userProjects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📊 Project Analytics",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text("Total Projects: ${userProjects.length}"),
          // Add more analytics here
        ],
      ),
    );
  }
}
