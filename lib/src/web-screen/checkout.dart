// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_management/src/service/event_service.dart';

class WebCheckOutPage extends StatefulWidget {
  final int eventId;

  const WebCheckOutPage({super.key, required this.eventId});

  @override
  _WebCheckinPageState createState() => _WebCheckinPageState();
}

class _WebCheckinPageState extends State<WebCheckOutPage> {
  late Future<List<Map<String, dynamic>>> _attendanceData;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attendanceData = getCheckedOutParticipants(widget.eventId);
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('HH:mm dd/MM/yy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void _handleCheckOut() {
    String qrCode = '';
    String inputName = _searchController.text.trim();
    if (inputName.isNotEmpty) {
      checkOut(widget.eventId, qrCode, inputName).then((responseData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-out successful for $inputName')),
        );
        setState(() {
          _attendanceData = getCheckedInParticipants(widget.eventId);
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-out failed: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Danh sách check-out',
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
                      onSubmitted: (_) => _handleCheckOut(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _handleCheckOut,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ), // Trigger on button press
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attendance Table Section
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _attendanceData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final participants = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20, // Increased spacing between columns
                      columns: const [
                        DataColumn(label: Text('Tên')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Check-Out')),
                      ],
                      rows: List.generate(
                        participants.length,
                        (index) => DataRow(cells: [
                          DataCell(Text(participants[index]['name'] ?? '')),
                          DataCell(Text(participants[index]['email'] ?? '')),
                          DataCell(Text(
                              formatDate(participants[index]['checkOutTime']))),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
