import 'package:flutter/material.dart';
import 'package:flutter_basic_starter_kit/presentation/screens/home/dashboard_screen.dart';
import 'package:flutter_basic_starter_kit/presentation/screens/home/profile_screen.dart';
import 'package:flutter_basic_starter_kit/presentation/widgets/app_bar_main.dart';
import 'package:flutter_basic_starter_kit/presentation/widgets/navigation_rail_custom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    DashboardScreen(),
    ProfileScreen(),
  ];

  final List<String> _labels = [
    "Dashboard",
    "Profile",
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Column(
          children: [
            AppBarMain(
              title: "HALA Build",
              onSearch: (value) {
                debugPrint("Search for: $value");
              },

              projectCount: 5,
              notifications: 2,
            ),
            Expanded(
              child: NavigationRailCustom(
                icons: _icons,
                labels: _labels,
                screens: _screens,
                initialIndex: 0,
                displayMode: NavigationDisplayMode.iconsAndLabels,
                enableLogout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
