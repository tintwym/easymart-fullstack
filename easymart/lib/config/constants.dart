import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    // Web runs in browser, must use a real reachable host
    if (kIsWeb) return "http://127.0.0.1:8000";

    // Android emulator uses special alias to host machine
    // iOS simulator can use localhost
    return defaultTargetPlatform == TargetPlatform.android
        ? "http://10.0.2.2:8000"
        : "http://localhost:8000";
  }

  static const primaryColorHex = 0xFF6A1B9A;
}
