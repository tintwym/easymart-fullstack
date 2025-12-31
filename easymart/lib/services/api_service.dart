import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for kIsWeb and defaultTargetPlatform
import 'package:http/http.dart' as http;
// import '../config/constants.dart'; // You can keep this if you have other constants

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static String? _authToken;
  final http.Client _client;

  /// ✅ FIXED: Dynamic Base URL for Docker/Localhost
  /// - Android Emulator needs 10.0.2.2
  /// - iOS Simulator & Web use localhost
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api'; // iOS
    }
  }

  static String? get authToken => _authToken;

  static void updateToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers({bool json = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    // ✅ Uses the dynamic getter
    final uri = Uri.parse('$baseUrl$path'); 
    try {
      final resp = await _client
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(resp);
    } catch (e) {
      throw ApiException('Connection failed: $e', statusCode: 0);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final resp = await _client
          .post(uri, headers: _headers(json: true), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(resp);
    } catch (e) {
      throw ApiException('Connection failed: $e', statusCode: 0);
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final resp = await _client
          .patch(uri, headers: _headers(json: true), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(resp);
    } catch (e) {
      throw ApiException('Connection failed: $e', statusCode: 0);
    }
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final resp = await _client
          .delete(uri, headers: _headers())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(resp);
    } catch (e) {
      throw ApiException('Connection failed: $e', statusCode: 0);
    }
  }

  dynamic _handleResponse(http.Response resp) {
    final status = resp.statusCode;
    if (status >= 200 && status < 300) {
      if (resp.body.isEmpty) return null;
      try {
        return jsonDecode(resp.body);
      } catch (e) {
        // Return body as string if it's not valid JSON
        return resp.body; 
      }
    }
    if (status == 401) {
      throw const ApiException('Unauthorized', statusCode: 401);
    }
    if (status == 404) {
      throw const ApiException('Not found', statusCode: 404);
    }
    throw ApiException(
      'API Error: ${resp.statusCode} ${resp.reasonPhrase ?? ''}',
      statusCode: status,
      body: resp.body,
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.body});
  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() =>
      'ApiException(status: $statusCode, message: $message, body: $body)';
}