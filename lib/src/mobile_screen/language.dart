import 'package:event_management/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:event_management/generated/l10n.dart';

class LanguageSelectionPage extends StatelessWidget {
  final SettingsController settingsController;

  const LanguageSelectionPage({Key? key, required this.settingsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context)!.language)),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context)!.english),
            onTap: () {
              settingsController.updateLocale(Locale('en', 'US'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(S.of(context)!.vietnamese),
            onTap: () {
              settingsController.updateLocale(Locale('vi', 'VN'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
