// ignore_for_file: use_build_context_synchronously

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Locale? _selectedLocale;

  final List<Locale> _supportedLocales = [
    const Locale('en', 'US'),
    const Locale('vi', 'VN'),
  ];

  @override
  void initState() {
    super.initState();
    userProfileUrl = user?.photoURL ?? "";
    _fetchUserName();
    _loadSavedLocale();
  }

  Future<void> _fetchUserName() async {
    try {
      setState(() {
        userName = user?.displayName ?? "";
      });
    } catch (e) {
      Navigator.pushNamed(context, "/login");
      LoggerService.logger.e("Failed to fetch user name: $e");
    }
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('selected_language');

    setState(() {
      if (savedLanguageCode != null) {
        _selectedLocale = _supportedLocales.firstWhere(
          (locale) => locale.languageCode == savedLanguageCode,
          orElse: () => _supportedLocales.first,
        );
      } else {
        _selectedLocale = _supportedLocales.first;
      }
    });

    await S.load(_selectedLocale!);
  }

  Future<void> _changeLanguage(Locale newLocale) async {
    if (_selectedLocale == newLocale) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLocale.languageCode);

    setState(() {
      _selectedLocale = newLocale;
    });

    await S.load(newLocale);
    Navigator.pushReplacementNamed(
        context, ModalRoute.of(context)!.settings.name!);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize =
        screenWidth > 940 ? 28 : (screenWidth > 860 ? 24 : 20);
    double buttonFontSize = screenWidth > 940
        ? 18
        : (screenWidth > 860 ? 16 : (screenWidth > 420 ? 14 : 10));

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Offstage(
            offstage: screenWidth < 725,
            child: _buildResponsiveButton(
                context, '/home', S.of(context).welcome_back, titleFontSize),
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
        const SizedBox(width: 4),
        _buildLanguageDropdown(),
        const SizedBox(width: 4),
        Offstage(
          offstage: MediaQuery.of(context).size.width < 567,
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

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: _selectedLocale,
        dropdownColor: Colors.lightBlueAccent,
        items: _supportedLocales.map((locale) {
          return DropdownMenuItem(
            value: locale,
            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  locale.languageCode == 'en' ? "English" : "Tiếng Việt",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            _changeLanguage(newLocale);
          }
        },
      ),
    );
  }
}
