// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/mobile_screen/add_special_participants.dart';
import 'package:event_management/src/mobile_screen/existed_participants.dart';
import 'package:event_management/src/mobile_screen/list_users_cancel.dart';
import 'package:event_management/src/mobile_screen/qr_scanner.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatefulWidget {
  final int eventId;
  final bool access;
  final bool allowSelectSchedule;
  final String status;

  const QuickActions({
    super.key,
    required this.eventId,
    required this.access,
    required this.allowSelectSchedule,
    required this.status,
  });

  @override
  // ignore: library_private_types_in_public_api
  _QuickActionsState createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  late bool access;
  late bool allowSelectSchedule;

  @override
  void initState() {
    super.initState();
    access = widget.access;
    allowSelectSchedule = widget.allowSelectSchedule;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Add Speaker and Guest Action Buttons
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.edit, "Điều chỉnh khách mời", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SpecialParticipantsPage(
                                  eventId: widget.eventId)));
                    }),
                    _buildActionButton(Icons.person, "Danh sách tham gia", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ExistedParticipants(id: widget.eventId)),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.status != "Cancelled"
                        ? _buildActionButton(Icons.cancel, "Hủy sự kiện",
                            () async {
                            cancelEvent(widget.eventId, context);
                          })
                        : _buildActionButton(
                            Icons.repeat_outlined, "Mở lại sự kiện", () {
                            resetEvent(widget.eventId, context);
                          }),
                    _buildActionButton(Icons.share, "Phân quyền", () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Remove Speaker and Guest Action Buttons
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                        Icons.description, "Documents", () async {}),
                    _buildActionButton(Icons.login, "Scan CheckIn", () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerPage(
                            onQRScanned: (qrCode) async {
                              await checkIn(widget.eventId, qrCode);
                            },
                          ),
                        ),
                      );
                    }),
                    _buildActionButton(Icons.logout, "Scan CheckOut", () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerPage(
                            onQRScanned: (qrCode) async {
                              await checkOut(widget.eventId, qrCode);
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                        Icons.money_outlined, "Chi Tiêu", () async {}),
                    _buildActionButton(
                        Icons.cancel_presentation, "Dữ liệu hủy tham gia", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CancelledUsersScreen(
                                  eventID: widget.eventId.toString(),
                                )),
                      );
                    }),
                    _buildActionButton(Icons.analytics, "Statistics", () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accessibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: access,
                  onChanged: (bool value) async {
                    setState(() {
                      access = value;
                    });

                    await updateEventAccess(widget.eventId, value);
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Register Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: allowSelectSchedule,
                  onChanged: (bool value) async {
                    setState(() {
                      allowSelectSchedule = value;
                    });

                    await updateEventAllow(widget.eventId, value);
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 28, color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
