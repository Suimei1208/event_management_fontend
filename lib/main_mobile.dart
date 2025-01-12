import 'package:event_management/firebase_options.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_app.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/settings/settings_controller.dart';
import 'package:event_management/src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  LoggerService.logger.i('Application is starting');

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  S.load(const Locale('en'));

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  LoggerService.logger
      .i("Current Platform: ${DefaultFirebaseOptions.currentPlatform}");
 
  runApp(MyMobileApp(settingsController: settingsController));
}
