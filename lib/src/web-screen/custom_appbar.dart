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
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          TextButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: Text(
                S.of(context).welcome_back,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              )),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            child: Text(
              S.of(context).home,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register-events'),
            child: Text(
              S.of(context).register_event,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forum'),
            child: Text(
              S.of(context).forum,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/manage-events'),
            child: Text(
              S.of(context).manage_event,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // TextButton(
          //   onPressed: () => Navigator.pushNamed(context, '/profile'),
          //   child: const Text(
          //     'Profile', // Replace with localization
          //     style: TextStyle(color: Colors.white, fontSize: 16),
          //   ),
          // ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Row(
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
        ),
      ],
      backgroundColor: Colors.lightBlueAccent,
    );
  }
}
