import 'package:flutter/material.dart';

class ToolsCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onActionPressed;

  const ToolsCard({
    super.key,
    required this.title,
    required this.description,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.shadow.withOpacity(0.0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: onActionPressed,
                child: const Text("Get Started"),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
