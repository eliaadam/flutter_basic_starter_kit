import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onNone; // Adding the action for None button
  final bool showBackButton; // New flag for controlling back button visibility

  final String title;
  final TextStyle? titleStyle;

  final List<Widget> centerChildren;
  final List<Widget> rightChildren;

  final Color? backgroundColor;
  final double height;

  const AppBarCustom({
    super.key,
    this.onBack, // Action for back button
    this.onHome, // Action for home button
    this.onNone, // Action for none button
    this.showBackButton = false, // New flag default to false (hidden)
    required this.title,
    this.titleStyle,
    this.centerChildren = const [],
    this.rightChildren = const [],
    this.backgroundColor = Colors.transparent,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: height,
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Left: Back or Home or None + Title
          Row(
            children: [
              if (showBackButton &&
                  onBack !=
                      null) // Show back button only if showBackButton is true
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                  onPressed: onBack ?? () => Navigator.pop(context),
                )
              else if (onHome != null)
                IconButton(
                  icon: Icon(Icons.home, color: colorScheme.primary),
                  onPressed:
                      onHome ??
                      () {
                        Navigator.pushNamed(context, '/home');
                      },
                )
              else if (onNone != null)
                Container() // If no button is needed, you can leave it as an empty container
              else
                Container(), // No button at all
              Text(title, style: TextStyle(fontSize: 18)),
            ],
          ),

          const Spacer(),

          /// Center
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: centerChildren,
          ),

          const Spacer(),

          /// Right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: rightChildren,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
