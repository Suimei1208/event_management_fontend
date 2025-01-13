import 'package:event_management/src/mobile_screen/feeback/setting_feed_back_cancel_event.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/widget/list_cancel_user.dart';
import 'package:event_management/widget/list_user_already_cancel.dart';

class CancelledUsersWebScreen extends StatefulWidget {
  final int eventID;

  const CancelledUsersWebScreen({super.key, required this.eventID});

  @override
  State<CancelledUsersWebScreen> createState() =>
      _CancelledUsersWebScreenState();
}

class _CancelledUsersWebScreenState extends State<CancelledUsersWebScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> cancelledUsers = [];
  final List<Map<String, dynamic>> alreadyCancelledUsers = [];
  late List<Widget> _pages;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCancelledUsers();
    _pages = [
      CancelledUsersPage(
        cancelledUsers: cancelledUsers,
        refreshData: _fetchCancelledUsers,
      ),
      AlreadyCancelledUsersPage(cancelledUsers: alreadyCancelledUsers),
      SettingCancelEvent(eventId: widget.eventID), // Add settings page here
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchCancelledUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Map<String, dynamic>> data =
          await fetchCancelledUsers(widget.eventID, 'Pending');
      List<Map<String, dynamic>> data2 =
          await fetchCancelledUsers(widget.eventID, 'Accepted');
      setState(() {
        cancelledUsers.clear();
        alreadyCancelledUsers.clear();
        cancelledUsers.addAll(data);
        alreadyCancelledUsers.addAll(data2);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      LoggerService.logger.i("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Row(
        children: [
          // Sidebar for navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.pending_actions),
                label: Text('Pending Requests'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cancel),
                label: Text('Cancelled Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Cancelled Users Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : IndexedStack(
                            index: _selectedIndex,
                            children: _pages,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SettingsPage Widget for the modal content
class SettingsPage extends StatelessWidget {
  final int eventID;

  const SettingsPage({super.key, required this.eventID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FractionallySizedBox(
        heightFactor: 0.9, // Adjust height of modal
        child: SettingCancelEvent(eventId: eventID),
      ),
    );
  }
}
