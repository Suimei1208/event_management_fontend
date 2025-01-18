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

class _CancelledUsersScreenState extends State<CancelledUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> cancelledUsers = [];
  final List<Map<String, dynamic>> alreadyCancelledUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCancelledUsers();
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingCancelEvent(
                    eventId: widget.eventID,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Danh sách chờ duyệt'),
            Tab(text: 'Danh sách đã hủy'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                CancelledUsersPage(
                    cancelledUsers: cancelledUsers,
                    refreshData: _fetchCancelledUsers),
                AlreadyCancelledUsersPage(
                    cancelledUsers: alreadyCancelledUsers),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
