import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class Config {
  static String get baseUrl {
    if (kIsWeb || Platform.isWindows) {
      return 'http://localhost';
    } else {
      return 'http://10.0.2.2'; 
    }
  }
}
