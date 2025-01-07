import 'package:event_management/src/mobile_screen/feeback/setting_feed_back_cancel_event.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/widget/list_cancel_user.dart';
import 'package:event_management/widget/list_user_already_cancel.dart';
import 'package:flutter/material.dart';

class CancelledUsersScreen extends StatefulWidget {
  final int eventID;

  const CancelledUsersScreen({super.key, required this.eventID});

  @override
  State<CancelledUsersScreen> createState() => _CancelledUsersScreenState();
}

class _CancelledUsersScreenState extends State<CancelledUsersScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> cancelledUsers = [];
  final List<Map<String, dynamic>> alreadyCancelledUsers = [];
  late List<Widget> _pages;
  bool isLoading = true; // Track if data is loading

  @override
  void initState() {
    super.initState();
    _fetchCancelledUsers();
    _pages = [
      CancelledUsersPage(
          cancelledUsers: cancelledUsers, refreshData: _fetchCancelledUsers),
      AlreadyCancelledUsersPage(cancelledUsers: alreadyCancelledUsers),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Cancelled Users'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingCancelEvent(
                    eventId: widget.eventID.toString(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => _onItemTapped(0),
                  child: Text(
                    'Danh sách chờ duyệt',
                    style: TextStyle(
                        color:
                            _selectedIndex == 0 ? Colors.orange : Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(1),
                  child: Text(
                    'Danh sách đã hủy',
                    style: TextStyle(
                        color:
                            _selectedIndex == 1 ? Colors.orange : Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
          ),
        ],
      ),
    );
  }
}
