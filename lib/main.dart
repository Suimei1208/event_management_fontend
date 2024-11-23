import 'package:event_management/firebase_options.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/app.dart';
import 'package:event_management/src/settings/settings_controller.dart';
import 'package:event_management/src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void main() async {
  _setupLogging();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  S.load(const Locale('en'));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp(settingsController: settingsController));
}

void _setupLogging() {
  // Thiết lập mức độ logging, có thể là ALL, FINE, INFO, WARNING, SEVERE
  Logger.root.level = Level.ALL;

  // Cấu hình handler cho logger (thường sẽ in ra console)
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}