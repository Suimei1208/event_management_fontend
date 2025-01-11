import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/user_service.dart';
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
      userName = await GetNameUser(context);
    } catch (e) {
      LoggerService.logger.e("Failed to fetch user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Text(
            'Welcome Back', // Replace with localization if needed
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            child: const Text(
              'Home', // Replace with localization
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register-event'),
            child: const Text(
              'Register Event', // Replace with localization
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forum'),
            child: const Text(
              'Forum', // Replace with localization
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/manage-events'),
            child: const Text(
              'Manage Event', // Replace with localization
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            child: const Text(
              'Profile', // Replace with localization
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Text(
              userName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundImage: (userProfileUrl.isNotEmpty)
                  ? NetworkImage(userProfileUrl)
                  : null,
              child: (userProfileUrl.isEmpty)
                  ? const Icon(Icons.person, size: 20, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
      backgroundColor: Colors.lightBlueAccent,
    );
  }
}
