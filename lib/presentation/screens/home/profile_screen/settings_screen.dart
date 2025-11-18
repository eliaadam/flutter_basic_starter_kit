import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("⚙️ Settings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notification Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
