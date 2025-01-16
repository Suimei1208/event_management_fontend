// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/participants/add_special_participants.dart';
import 'package:event_management/src/mobile_screen/document/document_page.dart';
import 'package:event_management/src/mobile_screen/event/event_analystic.dart';
import 'package:event_management/src/mobile_screen/participants/existed_participants.dart';
import 'package:event_management/src/mobile_screen/feeback/list_users_cancel.dart';
import 'package:event_management/src/mobile_screen/event/qr_scanner.dart';
import 'package:event_management/src/mobile_screen/event/share_role.dart';
import 'package:event_management/src/mobile_screen/spending/spending_overview.dart';
import 'package:event_management/src/models/checkedInData.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuickActions extends StatefulWidget {
  final int eventId;
  final bool access;
  final bool allowSelectSchedule;
  final String status;
  final String userRole;

  const QuickActions({
    super.key,
    required this.eventId,
    required this.access,
    required this.allowSelectSchedule,
    required this.status,
    required this.userRole,
  });

  @override
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
    // Check if the userRole is "Host-${widget.eventId}"
    bool isHost = widget.userRole == "Host-${widget.eventId}";
    bool isStaff = widget.userRole == "Staff-${widget.eventId}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
          if (isHost)
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
                      _buildActionButton(Icons.edit, S.of(context).edit_guest,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SpecialParticipantsPage(
                                    eventId: widget.eventId)));
                      }),
                      _buildActionButton(
                          Icons.person, S.of(context).list_participants, () {
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
          if (isHost)
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
                          Icons.description, S.of(context).documents, () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventResourcesPage(
                                    eventId: widget.eventId,
                                  )),
                        );
                      }),
                      widget.status != "Cancelled"
                          ? _buildActionButton(
                              Icons.cancel, S.of(context).cancel_event,
                              () async {
                              cancelEvent(widget.eventId, context);
                            })
                          : _buildActionButton(
                              Icons.repeat_outlined, S.of(context).reopen_event,
                              () {
                              resetEvent(widget.eventId, context);
                            }),
                      _buildActionButton(
                          Icons.share, S.of(context).decentralization, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ShareRolePage(eventId: widget.eventId)),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (isHost || isStaff)
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
                      _buildActionButton(Icons.login, "Scan CheckIn", () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScannerPage(
                              onQRScanned: (qrCode) async {
                                await checkIn(widget.eventId, qrCode, "");
                                getCheckedInParticipants(widget.eventId)
                                    .then((data) {
                                  Provider.of<CheckInData>(context,
                                          listen: false)
                                      .setAttendanceData(data);
                                });
                              },
                            ),
                          ),
                        );
                      }),
                      _buildActionButton(Icons.logout, "Scan CheckOut",
                          () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScannerPage(
                              onQRScanned: (qrCode) async {
                                await checkOut(widget.eventId, qrCode, "");
                                getCheckedInParticipants(widget.eventId)
                                    .then((data) {
                                  Provider.of<CheckInData>(context,
                                          listen: false)
                                      .setAttendanceData(data);
                                });
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
          if (isHost || isStaff)
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
                          Icons.money_outlined, S.of(context).spending,
                          () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SpendingOverviewPage(
                                    eventId: widget.eventId,
                                  )),
                        );
                      }),
                      _buildActionButton(
                          Icons.cancel_presentation, S.of(context).data_cancel,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CancelledUsersScreen(
                                    eventID: widget.eventId,
                                  )),
                        );
                      }),
                      _buildActionButton(
                          Icons.analytics, S.of(context).statistics, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventAnalyticsPage(
                                    eventId: widget.eventId,
                                  )),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).accessibility,
                  style: const TextStyle(
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
                Text(
                  S.of(context).register_schedule,
                  style: const TextStyle(
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
