import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    // Web runs in browser, must use a real reachable host
    if (kIsWeb) return "http://localhost:8000/api";

    // Android emulator uses special alias to host machine
    // iOS simulator can use localhost
    return defaultTargetPlatform == TargetPlatform.android
        ? "http://10.0.2.2:8000/api"
        : "http://localhost:8000/api";
  }

  static const primaryColorHex = 0xFF6A1B9A;
}
