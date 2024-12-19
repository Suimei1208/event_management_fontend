import 'package:event_management/src/service/auth_service.dart';
import 'package:event_management/src/service/user_service.dart'; // Import UserService
import 'package:event_management/widget/options_widget.dart';
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
  var role = '';

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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 30,
            ),
            onPressed: () {},
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Inter',
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor:
              brightness == Brightness.dark ? Colors.black : Colors.grey[200],
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
              role = userData['role'];

              return Column(
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
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1531123414780-f74242c2b052?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                    child: Text(
                                      userData['email'] ?? 'default@gmail.com',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                    child: Text(
                                      'Role: ${userData['role'] ?? 'None'}',
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
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
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
                  if (role == "organizer")
                    OptionsWidget(
                      icon: Icons.event_rounded,
                      text: "Your events",
                      onTap: () {
                        Navigator.pushNamed(context, '/user-events');
                      },
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
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
                      Navigator.pushNamed(context, '/create_event');
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
              );
            }

            return const Center(child: Text('No user data available'));
          },
        ),
      ),
    );
  }
}
