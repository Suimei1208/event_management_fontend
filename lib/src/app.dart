import 'package:event_management/src/mobile_screen/event/create_event.dart';
import 'package:event_management/src/mobile_screen/user/edit_profile.dart';
import 'package:event_management/src/mobile_screen/auth/forgot_password.dart';
import 'package:event_management/src/mobile_screen/event/home_screen.dart';
import 'package:event_management/src/mobile_screen/ticket/manage_ticket.dart';
import 'package:event_management/src/mobile_screen/auth/register.dart';
import 'package:event_management/src/mobile_screen/role_selection_screen.dart';
import 'package:event_management/src/mobile_screen/event/user_event.dart';
import 'package:event_management/src/service/notification_service.dart';
import 'package:event_management/src/settings/settings_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/mobile_screen/setting/language.dart';
import 'package:event_management/src/mobile_screen/auth/login.dart';
import 'package:event_management/src/mobile_screen/user/profile.dart';
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
                return const LoginScreen();
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
                    case LoginScreen.routeName:
                      return const LoginScreen();
                    case RoleSelectionScreen.routeName:
                      return const RoleSelectionScreen();
                    case RegisterScreen.routeName:
                      return const RegisterScreen();
                    case ProfileWidget.routeName:
                      return const ProfileWidget();
                    case ForgotPasswordScreen.routeName:
                      return const ForgotPasswordScreen();
                    case EditProfileScreen.routeName:
                      return const EditProfileScreen();
                    case CreateEvent.routeName:
                      return const CreateEvent();
                    case UserEvents.routeName:
                      return const UserEvents();
                    case MyTicketsPage.routeName:
                      return const MyTicketsPage();
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
