import 'package:event_management/src/mobile_screen/feeback/list_event_finished.dart';
import 'package:event_management/src/service/auth_service.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/widget/options_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_management/generated/l10n.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: Text(S.of(context).profile),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              final userData = snapshot.data!;

              return SingleChildScrollView(
                // Add SingleChildScrollView here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: brightness == Brightness.dark
                              ? Colors.grey[850]
                              : Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 50,
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: brightness == Brightness.dark
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: StreamBuilder<User?>(
                                  stream: FirebaseAuth.instance.userChanges(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.active) {
                                      final user = snapshot.data;
                                      final photoURL = user?.photoURL;
                                      return CircleAvatar(
                                        radius: 60,
                                        backgroundImage: (photoURL != null)
                                            ? NetworkImage(photoURL)
                                            : null,
                                        child: (photoURL == null)
                                            ? const Icon(Icons.person, size: 60)
                                            : null,
                                      );
                                    }
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData['name'] ?? 'Default',
                                      style: TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.0,
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(userData['nameFromEmail'] ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        )),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 4, 0, 0),
                                      child: Text(
                                        userData['email'] ??
                                            'default@gmail.com',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
                      child: Text(
                        S.of(context).account,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    OptionsWidget(
                      icon: Icons.account_circle_outlined,
                      text: S.of(context).editProfile,
                      onTap: () {
                        Navigator.pushNamed(context, '/edit_profile');
                      },
                    ),
                    OptionsWidget(
                      icon: Icons.confirmation_num,
                      text: S.of(context).myTicket,
                      onTap: () {
                        Navigator.pushNamed(context, '/my-ticket');
                      },
                    ),
                    OptionsWidget(
                      icon: Icons.thumb_up,
                      text: S.of(context).rate_event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const EventFinishedScreen()),
                        );
                      },
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
                      child: Text(
                        S.of(context).general,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    OptionsWidget(
                      icon: Icons.settings,
                      text: S.of(context).setting,
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    OptionsWidget(
                      icon: Icons.language,
                      text: S.of(context).language,
                      onTap: () {
                        Navigator.pushNamed(context, '/language');
                      },
                    ),
                    OptionsWidget(
                      icon: Icons.logout,
                      text: S.of(context).logout,
                      onTap: () {
                        logout(context);
                      },
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No user data available'));
          },
        ),
      ),
    );
  }
}
