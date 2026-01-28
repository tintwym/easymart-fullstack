import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    String host;
    if (kIsWeb) {
      host = "http://127.0.0.1:8000"; 
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      host = "http://10.0.2.2:8000"; 
    } else {
      host = "http://localhost:8000";
    }
    // Return with /api exactly once
    return "$host/api"; 
  }
}