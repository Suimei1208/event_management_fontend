// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late String userProfileUrl;
  late List<Event> events = [];
  String userName = "";

  @override
  void initState() {
    super.initState();
    userProfileUrl = user?.photoURL ?? "";
    fetchEvents();
    _fetchUserName(context);
  }

  Future<void> _fetchUserName(BuildContext context) async {
    try {
      userName = await GetNameUser(context);
    } catch (e) {
      LoggerService.logger.e("Failed to fetch user name: $e");
    }
  }

  Future<void> fetchEvents() async {
    List<Event> listEvents = await fetchEventById(user!.uid);
    List<Event> toRemove = [];

    for (var event in listEvents) {
      final ticket = await getQrTicket(event.id);
      if (ticket['statusTicket'] == "Cancelled") {
        toRemove.add(event);
      }
    }

    if (mounted) {
      setState(() {
        events = listEvents..removeWhere((event) => toRemove.contains(event));
      });
    }

    LoggerService.logger.i(events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).next_events,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              events.isEmpty
                  ? Center(
                      child: Text(S.of(context).no_events_available),
                    )
                  : Column(
                      children:
                          events.map((event) => buildEventCard(event)).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventCard(Event event) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${DateFormat.yMMMd().format(event.startDate)} - ${DateFormat.jm().format(event.startDate)}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              event.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.location,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> qrCode = await getQrTicket(event.id);
                    _viewQRCode(context, qrCode['qr']);
                  },
                  child: const Text('View Ticket'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewQRCode(BuildContext context, String qrCode) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final trimmedTimestamp = timestamp.length > 8
        ? timestamp.substring(timestamp.length - 8)
        : timestamp;
    final dynamicQrData = '$qrCode-$trimmedTimestamp';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: dynamicQrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
