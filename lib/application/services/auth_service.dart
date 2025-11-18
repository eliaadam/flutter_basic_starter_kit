import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basic_starter_kit/core/constants/app_constants.dart';
import 'package:flutter_basic_starter_kit/infrastructure/services/token_storage_service.dart';

class AuthService {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  AuthService(this._tokenStorage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          headers: {"Accept": "application/json"},
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

  Dio get dio => _dio;

  Future<String?> getAuthToken() async => _tokenStorage.getToken();

  /// Logs in user and stores token
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await _dio.post('/login', data: data);

    if (response.statusCode == 200 && response.data.containsKey('token')) {
      final token = response.data['token'];
      await _tokenStorage.saveToken(token);
      return {'success': true, 'message': 'Login successful!'};
    }

    String msg = 'Login failed';
    if (response.data is Map && response.data.containsKey('message')) {
      msg = response.data['message'];
    }

    return {'success': false, 'message': msg};
  }

  /// Registers user and auto-login on success
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    data['password_confirmation'] = data['password'];
    final response = await _dio.post('/register', data: data);

    debugPrint("Registration response: ${response.data}");

    if (response.statusCode == 201) {
      await login({'email': data['email'], 'password': data['password']});
      return {
        'success': true,
        'message': 'Successfully registered! Welcome 🎉',
      };
    }

    String msg = 'Registration failed';
    if (response.data is Map && response.data.containsKey('message')) {
      msg = response.data['message'];
    }

    return {'success': false, 'message': msg};
  }

  /// Logout user, delete token
  Future<Map<String, dynamic>> logout() async {
    final token = await _tokenStorage.getToken();

    if (token != null) {
      await _dio.post(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    }

    await _tokenStorage.deleteToken();

    return {'success': true, 'message': 'Logged out successfully'};
  }

  /// Fetch user profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await _tokenStorage.getToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    final response = await _dio.get(
      '/user',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data is Map) {
      return {
        'success': true,
        'data': Map<String, dynamic>.from(response.data),
      };
    }

    return {'success': false, 'message': 'Failed to load profile'};
  }
}
