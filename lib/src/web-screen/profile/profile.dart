import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:event_management/src/web-screen/profile/edit_profile.dart';
import 'package:event_management/src/web-screen/list_event_finished.dart';
import 'package:event_management/src/web-screen/manager_ticket.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_management/generated/l10n.dart';

class ProfileWebScreen extends StatefulWidget {
  const ProfileWebScreen({super.key});
  static const routeName = "/profile";

  @override
  State<ProfileWebScreen> createState() => _ProfileWebScreenState();
}

class _ProfileWebScreenState extends State<ProfileWebScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>> getUserDetails() async {
    // Implement your logic to fetch user details here
    // For example:
    return await getUserData(currentUser!.uid);
    // return {};
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: scaffoldKey,
        appBar: const CustomAppBar(),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: FutureBuilder<Map<String, dynamic>>(
              future: getUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final userData = snapshot.data!;

                  return SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Wrap the first container in an Expanded widget to handle layout properly
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                // color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: currentUser?.photoURL !=
                                            null
                                        ? NetworkImage(currentUser!.photoURL!)
                                        : null,
                                    child: currentUser?.photoURL == null
                                        ? const Icon(Icons.person,
                                            size: 60, color: Colors.grey)
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    userData['name'] ?? 'User Name',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userData['email'] ?? 'Email not available',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          // Wrap the second column in an Expanded widget for proper layout
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SectionTitle(text: S.of(context).account),
                                    const SizedBox(height: 10),
                                    OptionsCard(
                                      icon: Icons.account_circle_outlined,
                                      text: S.of(context).editProfile,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          WebEditProfileScreen.routeName,
                                        );
                                      },
                                    ),
                                    OptionsCard(
                                      icon: Icons.confirmation_num,
                                      text: S.of(context).myTicket,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          MyTicketsPageWeb.routeName,
                                        );
                                      },
                                    ),
                                    OptionsCard(
                                      icon: Icons.thumb_up,
                                      text: S.of(context).rate_event,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            EventFinishedScreenWeb.routeName);
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    SectionTitle(text: S.of(context).general),
                                    const SizedBox(height: 10),
                                    OptionsCard(
                                      icon: Icons.settings,
                                      text: S.of(context).setting,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/settings');
                                      },
                                    ),
                                    OptionsCard(
                                      icon: Icons.language,
                                      text: S.of(context).language,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/language');
                                      },
                                    ),
                                    OptionsCard(
                                      icon: Icons.logout,
                                      text: S.of(context).logout,
                                      onTap: () {
                                        logoutWeb(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('No user data available'));
              },
            ),
          ),
        ));
  }
}

// Helper Widgets
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class OptionsCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const OptionsCard({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: isDark ? Colors.white : Colors.blue),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
