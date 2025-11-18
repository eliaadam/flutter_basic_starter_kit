import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/database_helper.dart';
import 'package:flutter_basic_starter_kit/application/services/auth_service.dart';
import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/user_crud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserServiceAPI {
  final AuthService _authService;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  UserServiceAPI(this._authService);

  /// Login user + sync local DB
  Future<Map<String, dynamic>> login(String email, String password) async {
    final loginResult = await _authService.login({
      'email': email,
      'password': password,
    });

    if (loginResult['success'] == true) {
      final profileResult = await _authService.fetchUserProfile();
      final token = await _authService.getAuthToken();

      if (profileResult['success'] == true && token != null) {
        final userData = profileResult['data'];
        await _dbHelper.createUser(userData, token);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('logged_in_user_api_id', userData['id']);

        return {
          'success': true,
          'message': loginResult['message'] ?? 'Login successful',
        };
      }

      return {'success': false, 'message': 'Could not load user profile'};
    }

    return {
      'success': false,
      'message': loginResult['message'] ?? 'Login failed',
    };
  }

  /// Register + auto-login, and profile sync
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final registerResult = await _authService.register({
      'name': name,
      'email': email,
      'password': password,
    });

    if (registerResult['success'] == true) {
      final loginResult = await login(email, password);
      if (loginResult['success'] == true) {
        return {
          'success': true,
          'message': registerResult['message'] ?? 'Registered and logged in!',
        };
      }
    }

    return {
      'success': false,
      'message': registerResult['message'] ?? 'Registration failed',
    };
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    final result = await _authService.logout();
    return {'success': result['success'], 'message': result['message']};
  }

  /// Fetch user profile (pass-through)
  Future<Map<String, dynamic>> fetchUserProfile() async {
    return await _authService.fetchUserProfile();
  }
}
