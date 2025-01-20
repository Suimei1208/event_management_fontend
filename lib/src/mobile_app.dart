// lib/src/mobile_app.dart
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/mobile_screen/event/home_screen.dart';
import 'package:event_management/src/mobile_screen/auth/login.dart';
import 'package:event_management/src/mobile_screen/setting/language.dart';
import 'package:event_management/src/service/notification_service.dart';
import 'settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MyMobileApp extends StatefulWidget {
  const MyMobileApp({
    super.key,
    required this.settingsController,
  });
  final SettingsController settingsController;

  @override
  State<MyMobileApp> createState() => _MyMobileAppState();
}

class _MyMobileAppState extends State<MyMobileApp> {
  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: ThemeData(textTheme: GoogleFonts.robotoSlabTextTheme()),
          restorationScopeId: 'app',
          locale: widget.settingsController.locale,
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
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return const LoginScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case '/language':
                    return LanguageSelectionPage(
                        settingsController: widget.settingsController);
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case HomeScreen.routeName:
                    return const HomeScreen();
                  default:
                    return const LoginScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
