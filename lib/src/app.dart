import 'package:event_management/src/mobile_screen/event/home_screen.dart';

import 'package:event_management/src/service/notification_service.dart';
import 'package:event_management/src/settings/settings_view.dart';
import 'package:event_management/src/web-screen/create_event.dart';
import 'package:event_management/src/web-screen/detail_event.dart';
import 'package:event_management/src/web-screen/edit_profile.dart';
import 'package:event_management/src/web-screen/home.dart';
import 'package:event_management/src/web-screen/login.dart';
import 'package:event_management/src/web-screen/manager_ticket.dart';
import 'package:event_management/src/web-screen/profile.dart';
import 'package:event_management/src/web-screen/schedules.dart';
import 'package:event_management/src/web-screen/user_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/mobile_screen/setting/language.dart';
import 'package:event_management/src/mobile_screen/auth/login.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'settings/settings_controller.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          // theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return const HomeScreen();
              } else {
                return !kIsWeb ? const LoginScreen() : const WebLoginScreen();
              }
            },
          ),
          onGenerateRoute: (RouteSettings routeSettings) {
            if (!kIsWeb) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case '/language':
                      return LanguageSelectionPage(
                          settingsController: widget.settingsController);
                    case WebLoginScreen.routeName:
                      return const WebLoginScreen();
                    case SettingsView.routeName:
                      return SettingsView(
                        controller: widget.settingsController,
                      );
                    case HomeScreen.routeName:
                      return const HomeScreen();
                    default:
                      return const LoginScreen();
                  }
                },
              );
            } else {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  final uri = Uri.parse(routeSettings.name ?? '');
                  if (uri.pathSegments.length == 3 &&
                      uri.pathSegments.first == 'home' &&
                      uri.pathSegments[1] == 'detail-event') {
                    final id = int.tryParse(uri.pathSegments[2]);
                    if (id != null) {
                      return EventDetailsPageWeb(eventId: id);
                    }
                  }
                  if (uri.pathSegments.length == 4 &&
                      uri.pathSegments.first == 'home' &&
                      uri.pathSegments[1] == 'detail-event') {
                    final id = int.tryParse(uri.pathSegments[2]);
                    if (id != null) {
                      if (uri.pathSegments[3] == 'schedules') {
                        return WebSchedulesWidget(eventId: id);
                      }
                      return const WebHomeScreen();
                    }
                  }
                  switch (routeSettings.name) {
                    case '/language':
                      return LanguageSelectionPage(
                          settingsController: widget.settingsController);
                    case WebLoginScreen.routeName:
                      return const WebLoginScreen();
                    case WebHomeScreen.routeName:
                      return const WebHomeScreen();
                    case WebUserEvents.routeName:
                      return const WebUserEvents();
                    case WebCreateEvent.routeName:
                      return const WebCreateEvent();
                    case ProfileWebScreen.routeName:
                      return const ProfileWebScreen();
                    case WebEditProfileScreen.routeName:
                      return const WebEditProfileScreen();
                    case MyTicketsPageWeb.routeName:
                      return const MyTicketsPageWeb();
                    case SettingsView.routeName:
                      return SettingsView(
                        controller: widget.settingsController,
                      );
                    default:
                      return const WebLoginScreen();
                  }
                },
              );
            }
          },
        );
      },
    );
  }
}
