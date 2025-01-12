import 'package:flutter/material.dart';
import 'package:event_management/src/settings/settings_controller.dart';
import 'package:event_management/src/mobile_app.dart';

Widget getApp(SettingsController settingsController) {
  return MyMobileApp(settingsController: settingsController);
}
