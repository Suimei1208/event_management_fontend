// lib/src/web_app.dart
// ignore_for_file: unrelated_type_equality_checks

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/setting/language.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/settings/settings_view.dart';
import 'package:event_management/src/web-screen/add_special_participants.dart';
import 'package:event_management/src/web-screen/attendance_report_page.dart';
import 'package:event_management/src/web-screen/checkin.dart';
import 'package:event_management/src/web-screen/checkout.dart';
import 'package:event_management/src/web-screen/document_page.dart';
import 'package:event_management/src/web-screen/error.dart';
import 'package:event_management/src/web-screen/event_analystics.dart';
import 'package:event_management/src/web-screen/existed_participants.dart';
import 'package:event_management/src/web-screen/forum_screen.dart';
import 'package:event_management/src/web-screen/list_event_finished.dart';
import 'package:event_management/src/web-screen/list_user_cancel.dart';
import 'package:event_management/src/web-screen/manager_ticket.dart';
import 'package:event_management/src/web-screen/profile.dart';
import 'package:event_management/src/web-screen/register_event.dart';
import 'package:event_management/src/web-screen/request.dart';
import 'package:event_management/src/web-screen/share_roles.dart';
import 'package:event_management/src/web-screen/spending_overview.dart';
import 'package:event_management/src/web-screen/update_event.dart';
import 'package:event_management/src/web-screen/user_events.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/web-screen/create_event.dart';
import 'package:event_management/src/web-screen/edit_profile.dart';
import 'package:event_management/src/web-screen/home.dart';
import 'package:event_management/src/web-screen/login.dart';
import 'package:event_management/src/models/checkedInData.dart'; // Adjust the import path as needed
import 'package:provider/provider.dart';

// import 'package:googleapis/clouddeploy/v1.dart';
import 'settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_management/src/web-screen/schedules.dart';
import 'package:event_management/src/web-screen/detail_event.dart';

class MyWebApp extends StatefulWidget {
  const MyWebApp({
    super.key,
    required this.settingsController,
  });
  final SettingsController settingsController;

  @override
  State<MyWebApp> createState() => _MyWebAppState();
}

class _MyWebAppState extends State<MyWebApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => CheckInData(),
        child: ListenableBuilder(
          listenable: widget.settingsController,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              theme: ThemeData(
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: NoTransitionBuilder(),
                    TargetPlatform.iOS: NoTransitionBuilder(),
                  },
                ),
              ),
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
                    return const WebHomeScreen();
                  } else {
                    return const WebLoginScreen();
                  }
                },
              ),
              onGenerateRoute: (RouteSettings routeSettings) {
                return NoAnimationPageRoute<void>(
                    settings: routeSettings,
                    builder: (BuildContext context) {
                      final uri = Uri.parse(routeSettings.name ?? '');
                      if (uri.pathSegments.length == 3 &&
                          uri.pathSegments[1] == 'detail-event') {
                        final id = int.tryParse(uri.pathSegments[2]);
                        if (id != null) {
                          return FutureBuilder<Map<String, dynamic>>(
                            future: getEventData(id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError || snapshot.data == null) {
                                return const PageNotFoundPage();
                              }

                              return EventDetailsPageWeb(eventId: id);
                            },
                          );
                        }
                      }
                      if (uri.pathSegments.length == 4 &&
                          uri.pathSegments.first == 'home' &&
                          uri.pathSegments[1] == 'detail-event') {
                        final id = int.tryParse(uri.pathSegments[2]);
                        if (id != null) {
                          return buildDetailEventRoute(uri, id);
                        }
                      } else if (uri.pathSegments.length == 5 &&
                          uri.pathSegments.first == 'home' &&
                          uri.pathSegments[1] == 'detail-event' &&
                          uri.pathSegments[4] == 'detail-attendance') {
                        final id = int.tryParse(uri.pathSegments[2]);
                        if (id != null) {
                          return WebAttendanceReportPage(eventId: id);
                        }
                      } else if (uri.pathSegments.first == 'home' ||
                          uri.pathSegments.first == 'register-events' ||
                          uri.pathSegments.first == 'forum' ||
                          uri.pathSegments.first == 'manage-events' ||
                          uri.pathSegments.first == 'profile' ||
                          uri.pathSegments.first == 'edit-profile' ||
                          uri.pathSegments.first == 'my-tickets' ||
                          uri.pathSegments.first == 'finished-events' ||
                          uri.pathSegments.first == 'settings' ||
                          uri.pathSegments.first == 'language') {
                      } else {
                        return const PageNotFoundPage();
                      }
                      switch (routeSettings.name) {
                        case '/language':
                          return LanguageSelectionPage(
                              settingsController: widget.settingsController);
                        case WebLoginScreen.routeName:
                          return const WebLoginScreen();
                        case WebHomeScreen.routeName:
                          return const WebHomeScreen();
                        case WebCreateEvent.routeName:
                          return const WebCreateEvent();
                        case WebEditProfileScreen.routeName:
                          return const WebEditProfileScreen();
                        case EventRegisterWebScreen.routeName:
                          return const EventRegisterWebScreen();
                        case WebCommunityForumScreen.routeName:
                          return const WebCommunityForumScreen();
                        case WebUserEvents.routeName:
                          return const WebUserEvents();
                        case ProfileWebScreen.routeName:
                          return const ProfileWebScreen();
                        case EventFinishedScreenWeb.routeName:
                          return const EventFinishedScreenWeb();
                        case MyTicketsPageWeb.routeName:
                          return const MyTicketsPageWeb();
                        // case CreatePostScreenWeb.routeName:
                        //   return const CreatePostScreenWeb();
                        case SettingsView.routeName:
                          return SettingsView(
                              controller: widget.settingsController);
                        default:
                          return const WebLoginScreen();
                      }
                    });
              },
            );
          },
        ));
  }
}

Widget buildDetailEventRoute(Uri uri, int eventId) {
  return FutureBuilder<String?>(
    future: fetchUserRole(eventId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || snapshot.data == null) {
        return const PageNotFoundPage();
      }

      final userRole = snapshot.data!;
      if (userRole != "Host-$eventId" && userRole != "Staff-$eventId") {
        return const PageNotFoundPage();
      }

      final subPath = uri.pathSegments[3];
      switch (subPath) {
        case 'schedules':
          return WebSchedulesWidget(eventId: eventId);
        case 'pending-requests':
          return RequestPageWeb(eventId: eventId);
        case 'special-participants':
          return WebSpecialParticipantsPage(eventId: eventId);
        case 'existed-participants':
          return ExistedParticipantsWeb(eventId: eventId);
        case 'documents':
          return WebEventResourcesPage(eventId: eventId);
        case 'share-roles':
          return WebShareRolePage(eventId: eventId);
        case 'spending':
          return WebSpendingOverviewPage(eventId: eventId);
        case 'event-analystics':
          return EventAnalyticsWebPage(eventId: eventId);

        case 'list-cancelled-users':
          return CancelledUsersWebScreen(eventID: eventId);
        case 'edit-event':
          return UpdateEventWeb(eventId: eventId);
        case 'check-in':
          return WebCheckinPage(eventId: eventId);
        case 'check-out':
          return WebCheckOutPage(eventId: eventId);
        default:
          return const PageNotFoundPage();
      }
    },
  );
}

Future<String?> fetchUserRole(int eventId) {
  return fetchParticipantRoleByUserIdAndEventId(eventId).then((participant) {
    LoggerService.logger.i(participant?.role);
    return participant?.role;
  }).catchError((e) {
    LoggerService.logger.e("Error fetching user role: $e");
    return null;
  });
}

class NoTransitionBuilder extends PageTransitionsBuilder {
  @override
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child; // Không có hiệu ứng chuyển cảnh
  }
}

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required super.builder, super.settings});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
