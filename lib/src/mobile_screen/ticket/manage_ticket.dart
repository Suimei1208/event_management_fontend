// ignore_for_file: library_private_types_in_public_api


import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/ticket/form_cancel_ticket.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/ticket_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_management/src/models/tickets.dart';
// ignore: unused_import
import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  static const routeName = '/my-ticket';

  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchTickets();
  }

  String text(String status) {
    if (status == "Pending") {
      return "Đang chờ xử lý";
    } else if (status == "Accepted") {
      return "Đã được chấp nhận";
    } else if (status == "Rejected") {
      return "Đã bị từ chối";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).myTicket),
        // backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tickets available.'),
            );
          }

          final tickets = snapshot.data!;
          // for (var ticket in tickets) {
          //   LoggerService.logger.i(ticket.cancel_status);
          //   LoggerService.logger.i(ticket.status);
          // }
          final upcomingTickets = tickets
              .where((ticket) =>
                  ticket.eventStatus == 'Upcoming' ||
                  ticket.eventStatus == 'Ongoing')
              .toList();
          final pastTickets = tickets
              .where((ticket) => ticket.eventStatus == 'Completed')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'View and manage your event tickets',
                //   style: TextStyle(fontSize: 16, color: Colors.grey),
                // ),
                // const SizedBox(height: 24),
                _buildEventSection(context, 'Upcoming Events', upcomingTickets),
                const SizedBox(height: 24),
                _buildEventSection(context, 'Past Events', pastTickets),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventSection(
      BuildContext context, String title, List<Ticket> tickets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 16),
        if (tickets.isEmpty)
          const Center(child: Text('No tickets available in this category.')),
        ...tickets.map((ticket) => _buildEventCard(context, ticket)),
      ],
    );
  }

  Widget buildTicketCancellationWidget(Ticket ticket, BuildContext context) {
    final displayStatus =
        ticket.eventStatus == "Completed" ? "Expired" : ticket.eventStatus;
    if (displayStatus == "Expired") {
      return Column(
        children: [
          const Text(""),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Expired'),
          ),
        ],
      );
    } else {
      if (ticket.cancellationStartDate != null &&
          ticket.cancellationEndDate != null) {
        if (DateTime.now().isAfter(ticket.cancellationStartDate!) &&
            DateTime.now().isBefore(ticket.cancellationEndDate!)) {
          if (ticket.cancel_status == "None") {
            return Column(
              children: [
                Text(text(ticket.cancel_status!)),
                ElevatedButton(
                  onPressed: () async {
                    if (ticket.cancellationLink != null &&
                        ticket.cancellationLink!.isNotEmpty) {
                      final Uri url = Uri.parse(ticket.cancellationLink!);
                      if (url.isAbsolute) {
                        await launchUrl(url);
                      } else {
                        LoggerService.logger.e("Invalid cancellation link");
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketCancellationForm(
                            eventId: ticket.eventId,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Hủy vé'),
                ),
              ],
            );
          } else if (ticket.status == "Cancelled" &&
              ticket.cancel_status == "Accepted") {
            return Column(
              children: [
                Text(text(ticket.cancel_status!)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: null,
                  child: const Text('Hủy vé'),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Text(text(ticket.cancel_status!)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: null,
                  child: const Text('Hủy vé'),
                ),
              ],
            );
          }
        } else if (DateTime.parse(ticket.startDate).isAfter(DateTime.now())) {
          return Column(
            children: [
              Text(ticket.status == "Cancelled" ? "Vé đã bị hủy" : ""),
              ElevatedButton(
                onPressed: ticket.status == "Cancelled"
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const DialogWidget(
                              message:
                                  'Vui lòng liên hệ Admin qua email để hủy vé!',
                              title: 'Notification',
                            );
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Hủy vé'),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              const Text(""),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const DialogWidget(
                        message: 'Vui lòng liên hệ Admin qua email để hủy vé!',
                        title: 'Notification',
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Hủy vé'),
              ),
            ],
          );
        }
      } else {
        return Column(
          children: [
            const Text(""),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const DialogWidget(
                      message: 'Vui lòng liên hệ Admin qua email để hủy vé!',
                      title: 'Notification',
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Hủy vé'),
            ),
          ],
        );
      }
    }
  }

  Widget _buildEventCard(BuildContext context, Ticket ticket) {
    // Dynamically adjust the event status
    final displayStatus =
        ticket.eventStatus == "Completed" ? "Expired" : ticket.eventStatus;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEventDetails(
                    ticket.eventName, formatDateTime(ticket.startDate)),
                _buildEventImage(ticket.eventBannerUrl),
              ],
            ),
            const Divider(height: 24, color: Colors.deepPurple),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTicketDetails('Ticket Status:', displayStatus),
                _buildTicketDetails(
                    'Ticket #:',
                    ticket.qrCode.length > 6
                        ? ticket.qrCode.substring(ticket.qrCode.length - 6)
                        : ticket.qrCode),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                buildTicketCancellationWidget(ticket, context),
                Column(
                  children: [
                    const Text(""),
                    ElevatedButton(
                      onPressed: () => _viewQRCode(context, ticket.qrCode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.purple
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('View QR Code'),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetails(String eventName, String eventDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eventName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            // color: Colors.black,
          ),
        ),
        Text(
          eventDate,
          style: const TextStyle(
            fontSize: 14,
            // color: Colors.grey
          ),
        ),
      ],
    );
  }

  Widget _buildEventImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        '$imageUrl?updatedAt=${DateTime.now().millisecondsSinceEpoch}',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTicketDetails(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _viewQRCode(BuildContext context, String qrCode) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final trimmedTimestamp = timestamp.length > 8
        ? timestamp.substring(timestamp.length - 8)
        : timestamp;
    final dynamicQrData = '$qrCode-$trimmedTimestamp';

    showModalBottomSheet(
      backgroundColor: Colors.white,
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    final formatter = DateFormat('dd-MM-yyyy - HH:mm:ss');
    return formatter.format(parsedDate);
  }
}
