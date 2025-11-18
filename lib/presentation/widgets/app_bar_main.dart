import 'package:flutter/material.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/database_helper.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/user_crud.dart';

class AppBarMain extends StatefulWidget {
  final bool showBackButton;
  final bool showHomeButton;
  final String title;
  final Function(String) onSearch;
  final int projectCount;
  final int notifications;

  const AppBarMain({
    super.key,
    this.showBackButton = false,
    this.showHomeButton = false,
    required this.title,
    required this.onSearch,
    this.projectCount = 0,
    this.notifications = 0,
  });

  @override
  State<AppBarMain> createState() => _AppBarMainState();
}

class _AppBarMainState extends State<AppBarMain> {
  String profileName = 'Loading...';
  String subscriptionPackage = 'Loading...';
  String profileImageUrl = 'https://placehold.co/600x400.png';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final db = DatabaseHelper();
    final user = await db.getCurrentUserWithSubscription();

    if (mounted && user != null) {
      setState(() {
        profileName = user['name'] ?? 'Unknown';
        subscriptionPackage = user['subscription'] ?? 'No Plan';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Left side (Back/Home/None)
          if (widget.showBackButton)
            IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.primary),
              onPressed: () => Navigator.pop(context),
            )
          else if (widget.showHomeButton)
            IconButton(
              icon: Icon(Icons.home, color: colorScheme.primary),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),

          const SizedBox(width: 8),
          Text('HALA Build', style: TextStyle(fontSize: 18)),

          const Spacer(),

          // Center (Search)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorHeight: 16,
                    cursorWidth: 1,
                    onSubmitted: widget.onSearch,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '  Search...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search, color: colorScheme.primary),
                  onPressed: () {
                    // Optional search button logic
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Right side (Username & Subscription)
          Row(
            children: [
              Text(
                subscriptionPackage,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                profileName,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
                radius: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
