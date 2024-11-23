import 'package:event_management/src/mobile_screen/register.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:event_management/src/mobile_screen/language.dart';
import 'package:event_management/src/mobile_screen/login.dart';
import 'package:event_management/src/mobile_screen/profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'settings/settings_controller.dart';
import 'package:event_management/generated/l10n.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          locale: settingsController.locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('vi', 'VN'),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)?.appTitle ?? 'Default Title',
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            if (!kIsWeb) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case '/language':
                      return LanguageSelectionPage(settingsController: settingsController);
                    case LoginScreen.routeName:
                      return const LoginScreen();
                    case RegisterScreen.routeName:
                      return const RegisterScreen();
                    case ProfileWidget.routeName:
                      return const ProfileWidget();
                    default:
                      return const LoginScreen();
                  }
                },
              );
            }
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                return const LoginScreen();
              },
            );
          },
        );
      },
    );
  }
}
