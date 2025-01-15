// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:event_management/src/models/checkedInData.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:event_management/src/service/event_service.dart';

class WebCheckinPage extends StatefulWidget {
  final int eventId;

  const WebCheckinPage({super.key, required this.eventId});

  @override
  _WebCheckinPageState createState() => _WebCheckinPageState();
}

class _WebCheckinPageState extends State<WebCheckinPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    // Load the attendance data from the database and update the provider
    getCheckedInParticipants(widget.eventId).then((data) {
      Provider.of<CheckInData>(context, listen: false).setAttendanceData(data);
    });
  }

  void _handleCheckIn() {
    String qrCode = '';
    String inputName = _searchController.text.trim();
    if (inputName.isNotEmpty) {
      checkIn(widget.eventId, qrCode, inputName).then((responseData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in successful for $inputName')),
        );

        // Reload attendance data after check-in
        _loadAttendanceData();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in failed: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('HH:mm dd/MM/yy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the attendance data from the provider
    List<Map<String, dynamic>> participants =
        Provider.of<CheckInData>(context).attendanceData;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Danh sách check-in',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Search Bar Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Nhập MSSV',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _handleCheckIn(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _handleCheckIn,
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attendance Table Section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20, // Increased spacing between columns
                  columns: const [
                    DataColumn(label: Text('Tên')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Check-In')),
                  ],
                  rows: List.generate(
                    participants.length,
                    (index) => DataRow(cells: [
                      DataCell(Text(participants[index]['name'] ?? '')),
                      DataCell(Text(participants[index]['email'] ?? '')),
                      DataCell(Text(formatDate(
                          participants[index]['checkInTime'] ?? ''))),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
