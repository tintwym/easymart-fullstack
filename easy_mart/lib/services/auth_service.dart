import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;

  // Use the centralized baseUrl from your constants
  final String _baseUrl = AppConstants.baseUrl;

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'), // Fixed endpoint path
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']); // Save token for persistence
        
        // Map the ULID-compatible user model
        _user = UserModel.fromJson(data['user']);
        notifyListeners();
        return null; // Success
      } else {
        return data['message'] ?? 'Login failed';
      }
    } catch (e) {
      return 'Connection Error: $e';
    }
  }

  Future<String?> register(String name, String email, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) { // Laravel returns 201 for Created
        return null; 
      } else {
        return data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      return 'Connection Error: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    notifyListeners();
  }
}