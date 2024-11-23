import 'package:event_management/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:event_management/generated/l10n.dart';

class LanguageSelectionPage extends StatelessWidget {
  final SettingsController settingsController;

  const LanguageSelectionPage({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context)!.language)),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context)!.english),
            onTap: () {
              settingsController.updateLocale(const Locale('en', 'US'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(S.of(context)!.vietnamese),
            onTap: () {
              settingsController.updateLocale(const Locale('vi', 'VN'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
