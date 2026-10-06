import 'package:flutter/foundation.dart';

class ApiConfig {
  // Host IP for backend connection:
  // - Linux Desktop / Web -> localhost
  // - Android Emulator -> 10.0.2.2 or 192.168.1.43
  // - Real Physical Phone -> 192.168.1.43
  static String customHost = '10.0.2.2';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$customHost:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const Duration timeout = Duration(seconds: 15);
}
