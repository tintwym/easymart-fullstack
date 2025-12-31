import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  String? token;
  bool loading = false;
  
  // 1. Add this flag to track if we finished checking storage
  bool isInitialized = false; 

  final AuthService _service = AuthService();

  // 2. Add Constructor: Automatically check session when app starts
  AuthProvider() {
    tryAutoLogin();
  }

  // ------------------------------------
  // 🚀 1. Auto Login (Check Storage)
  // ------------------------------------
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey('token')) {
      // 3. Important: Mark initialization as done even if no token found
      isInitialized = true; 
      notifyListeners();
      return false;
    }

    token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final email = prefs.getString('email');
    final name = prefs.getString('name');

    if (token != null && userId != null) {
      ApiService.updateToken(token);
      user = UserModel(
        id: userId,
        email: email ?? '',
        displayName: name ?? 'User',
      );
    }
    
    // 4. Mark initialization as done
    isInitialized = true; 
    notifyListeners();
    return true;
  }

  // ------------------------------------
  // 🔑 2. Login
  // ------------------------------------
  Future<bool> login(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      final res = await _service.login(email, password);

      if (res == null) throw Exception('Invalid response');
      
      token = res['access_token']?.toString();
      final userId = res['user_id']?.toString();
      final userName = res['user_name']?.toString() ?? 'User';

      if (token == null || userId == null) {
        throw Exception('Missing token or user ID');
      }

      ApiService.updateToken(token);

      user = UserModel(
        id: userId,
        email: email,
        displayName: userName,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setString('userId', userId);
      await prefs.setString('email', email);
      await prefs.setString('name', userName);

      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Login Error: $e");
      loading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------
  // 📝 3. Register
  // ------------------------------------
  Future<bool> register(String email, String password, String displayName) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _service.register(email, password, displayName);
      if (res == null) {
        loading = false;
        notifyListeners();
        return false;
      }
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------
  // 🚪 4. Logout
  // ------------------------------------
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    user = null;
    token = null;
    ApiService.updateToken(null);
    notifyListeners();
  }
}