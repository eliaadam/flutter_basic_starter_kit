import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String screenDescription;

  const PlaceholderScreen({super.key, required this.screenDescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Under development : $screenDescription ...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
