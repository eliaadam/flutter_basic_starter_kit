import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basic_starter_kit/application/services/auth_service.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/database_helper.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/user_crud.dart';
import 'package:flutter_basic_starter_kit/infrastructure/services/token_storage_service.dart';
import 'package:flutter_basic_starter_kit/presentation/screens/home/profile_screen/activity_log_screen.dart';
import 'package:flutter_basic_starter_kit/presentation/screens/home/profile_screen/user_info_screen.dart';
import 'package:flutter_basic_starter_kit/presentation/widgets/navigation_rail_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TokenStorageService _tokenStorage;
  late final AuthService _authService;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<String, dynamic>? userData;
  String? subscription;
  List<Map<String, dynamic>> userProjects = [];
  List<Map<String, dynamic>> activityLogs = [];
  String? token;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorageService();
    _authService = AuthService(_tokenStorage);
    _initProfile();
  }

  Future<void> _initProfile() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await _loadLocalProfile();
  }

  Future<void> _loadLocalProfile() async {
    try {
      if (kDebugMode) print("Loading profile from local DB...");

      final prefs = await SharedPreferences.getInstance();
      final apiUserId = prefs.getInt('logged_in_user_api_id');
      final fetchedToken = await _authService.getAuthToken();

      if (apiUserId == null) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'api_id = ?',
        whereArgs: [apiUserId],
        limit: 1,
      );

      if (result.isEmpty) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final subscriptionData = await _dbHelper.getCurrentUserWithSubscription();
      final activities = await _getActivityLog();

      setState(() {
        userData = result.first;
        token = fetchedToken;
        subscription = subscriptionData?['subscription'] ?? 'None';
        activityLogs = activities;
        isLoading = false;
        hasError = false;
      });

      if (kDebugMode) debugPrint(jsonEncode(userData));
    } catch (e) {
      if (kDebugMode) print("Error loading local profile: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getActivityLog() async {
    final userId = await _dbHelper.getLoggedInUserId();
    if (userId == null) return [];
    final db = await _dbHelper.database;
    return await db.query(
      'user_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time_performed DESC',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || userData == null || token == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Failed to load user data"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initProfile,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NavigationRailCustom(
        icons: const [Icons.person, Icons.history],
        labels: const ["Profile", "Activity"],
        screens: [
          UserInfoScreen(userData: userData!, subscription: subscription!),
          ActivityLogScreen(activityLogs: activityLogs),
        ],
        initialIndex: 0,
        displayMode: NavigationDisplayMode.iconsAndLabels,
      ),
    );
  }
}
