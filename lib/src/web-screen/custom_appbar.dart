import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.actions,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  User? user = FirebaseAuth.instance.currentUser;
  late String userProfileUrl;
  String userName = "";

  @override
  void initState() {
    super.initState();
    userProfileUrl = user?.photoURL ?? "";
    _fetchUserName(context);
  }

  Future<void> _fetchUserName(BuildContext context) async {
    try {
      userName = user?.displayName ?? "";
    } catch (e) {
      Navigator.pushNamed(context, "/login");
      LoggerService.logger.e("Failed to fetch user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double titleFontSize =
        screenWidth > 860 ? 28 : (screenWidth > 740 ? 24 : 20);
    double buttonFontSize =
        screenWidth > 860 ? 20 : (screenWidth > 740 ? 18 : 14);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Offstage(
            offstage: screenWidth < 635,
            child: _buildResponsiveButton(
                context, '/home', 'Welcome Back', titleFontSize),
          ),
          const Spacer(),
          _buildResponsiveButton(
              context, '/home', S.of(context).home, buttonFontSize),
          _buildResponsiveButton(context, '/register-events',
              S.of(context).register_event, buttonFontSize),
          _buildResponsiveButton(
              context, '/forum', S.of(context).forum, buttonFontSize),
          _buildResponsiveButton(context, '/manage-events',
              S.of(context).manage_event, buttonFontSize),
        ],
      ),
      actions: [
        Offstage(
          offstage: MediaQuery.of(context).size.width < 510,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Row(
              children: [
                Text(
                  userName,
                  style:
                      TextStyle(color: Colors.white, fontSize: buttonFontSize),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: (userProfileUrl.isNotEmpty)
                      ? NetworkImage(userProfileUrl)
                      : null,
                  child: (userProfileUrl.isEmpty)
                      ? Icon(Icons.person,
                          size: buttonFontSize, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ],
      backgroundColor: Colors.lightBlueAccent,
    );
  }

  Widget _buildResponsiveButton(
      BuildContext context, String route, String label, double fontSize) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
