import 'package:flutter/material.dart';
import 'package:event_management/src/settings/settings_controller.dart';
import 'package:event_management/src/web_app.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Widget getApp(SettingsController settingsController) {
  setUrlStrategy(PathUrlStrategy());
  return MyWebApp(settingsController: settingsController);
}
