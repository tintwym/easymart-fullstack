import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  Dio? _dio;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // Change this to your local IP if running on a real device
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  static const String _baseUrl = 'http://localhost:8000';

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    // Basic Dio setup
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Accept': 'application/json',
        'Referer': _baseUrl, 
      },
      contentType: 'application/json',
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    // Cookie management for Session Auth
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var cookieJar = PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));
    _dio!.interceptors.add(CookieManager(cookieJar));
    
    // Check if we are already logged in
    await getUser();
  }

  Future<void> _getCsrfToken() async {
    if (_dio == null) return;
    try {
      await _dio!.get('/sanctum/csrf-cookie');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting CSRF token: $e');
      }
    }
  }

  Future<String?> login(String email, String password) async {
    if (_dio == null) return 'Network error: Dio not initialized';
    
    try {
      await _getCsrfToken();

      final response = await _dio!.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        await getUser();
        return null;
      } else {
        if (kDebugMode) {
          print('Login failed: ${response.data}');
        }
        String errorMessage = response.statusMessage ?? 'Unknown error';
        if (response.data is Map<String, dynamic> && response.data['message'] != null) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
           errorMessage = response.data;
        }
         return 'Login failed: $errorMessage';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
       if (e is DioException) {
        return 'Error: ${e.response?.data['message'] ?? e.message}';
      }
      return 'Error: $e';
    }
  }

  Future<String?> register(String name, String email, String password, String confirmPassword) async {
    if (_dio == null) return 'Network error: Dio not initialized';

    try {
      await _getCsrfToken();

      final response = await _dio!.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        await getUser();
        return null; // Success
      } else {
         if (kDebugMode) {
          print('Register failed: ${response.data}');
        }
        String errorMessage = response.statusMessage ?? 'Unknown error';
        if (response.data is Map<String, dynamic> && response.data['message'] != null) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
           errorMessage = response.data;
        }
        return 'Registration failed: $errorMessage';
      }
    } catch (e) {
       if (kDebugMode) {
        print('Register error: $e');
      }
      if (e is DioException) {
        return 'Error: ${e.response?.data['message'] ?? e.message}';
      }
      return 'Error: $e';
    }
  }

  Future<void> getUser() async {
    if (_dio == null) return;

    try {
      final response = await _dio!.get('/api/user');
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data);
        notifyListeners();
      } else {
        _user = null;
        notifyListeners();
      }
    } catch (e) {
       _user = null;
       notifyListeners();
    }
  }

  Future<void> logout() async {
     if (_dio == null) return;
     try {
       await _dio!.post('/logout');
     } finally {
       _user = null;
       notifyListeners();
     }
  }
}
