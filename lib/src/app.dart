import 'package:event_management/src/mobile_screen/create_event.dart';
import 'package:event_management/src/mobile_screen/edit_profile.dart';
import 'package:event_management/src/mobile_screen/forgot_password.dart';
import 'package:event_management/src/mobile_screen/home_screen.dart';
import 'package:event_management/src/mobile_screen/register.dart';
import 'package:event_management/src/mobile_screen/register_events.dart';
import 'package:event_management/src/mobile_screen/role_selection_screen.dart';
import 'package:event_management/src/mobile_screen/user_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/mobile_screen/language.dart';
import 'package:event_management/src/mobile_screen/login.dart';
import 'package:event_management/src/mobile_screen/profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'settings/settings_controller.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
          theme: ThemeData(textTheme: GoogleFonts.robotoSlabTextTheme()),
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
          // theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
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
                          settingsController: settingsController);
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
                    case HomeScreen.routeName:
                      return const HomeScreen();
                    case EventListScreen.routeName:
                      return const EventListScreen();
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
