import 'package:flutter/material.dart';

class CustomTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  const CustomTooltip({super.key, required this.child, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 3),
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      message: message,
      child: child,
    );
  }
}
