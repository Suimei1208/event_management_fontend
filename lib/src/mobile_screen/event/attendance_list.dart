// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

class AttendanceReportPage extends StatefulWidget {
  final int eventId;

  const AttendanceReportPage({super.key, required this.eventId});

  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  late Future<List<Map<String, dynamic>>> _attendanceData;

  @override
  void initState() {
    super.initState();
    _attendanceData = getCheckedInAndCheckedOutParticipants(widget.eventId);
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('HH:mm dd/MM/yy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> participants) async {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];

    // Set headers manually
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Name');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Check-In');
    sheet.cell(CellIndex.indexByString('C1')).value =
        TextCellValue('Check-Out');

    for (int i = 0; i < participants.length; i++) {
      final participant = participants[i];
      sheet.cell(CellIndex.indexByString('A${i + 2}')).value =
          TextCellValue(participant['name'] ?? '');
      sheet.cell(CellIndex.indexByString('B${i + 2}')).value =
          TextCellValue(formatDate(participant['checkInTime']));
      sheet.cell(CellIndex.indexByString('C${i + 2}')).value =
          TextCellValue(formatDate(participant['checkOutTime']));
    }

    await _requestPermission(Permission.storage);

    const downloadFolderPath = '/storage/emulated/0/Download/';
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = "${timestamp}_Attendance_Report.xlsx";
    String filePath = '$downloadFolderPath/$fileName';

    // Write Excel file
    final fileBytes = excel.save();
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xuất báo cáo Excel thành công: $filePath')),
    );
  }

  Future<void> exportToPDF(List<Map<String, dynamic>> participants) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text('Report Event Attendance',
                  style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Name', 'Check-In', 'Check-Out'],
                data: participants.map((p) {
                  return [
                    p['name'] ?? '',
                    formatDate(p['checkInTime']),
                    formatDate(p['checkOutTime']),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await _requestPermission(Permission.storage);

    const downloadFolderPath = '/storage/emulated/0/Download/';
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = "${timestamp}_Attendance_Report.pdf";
    String filePath = '$downloadFolderPath/$fileName';

    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xuất báo cáo PDF thành công: $filePath')),
    );
  }

  // Helper method to request permission
  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      LoggerService.logger.i('Permission granted');
    } else {
      LoggerService.logger.e('Permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo Cáo Tham Gia Sự Kiện')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Báo cáo chi tiết',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
                      columns: const [
                        DataColumn(label: Text('Tên')),
                        DataColumn(label: Text('Check-In')),
                        DataColumn(label: Text('Check-Out')),
                      ],
                      rows: List.generate(
                        participants.length,
                        (index) => DataRow(cells: [
                          DataCell(Text(participants[index]['name'] ?? '')),
                          DataCell(Text(
                              formatDate(participants[index]['checkInTime']))),
                          DataCell(Text(
                              formatDate(participants[index]['checkOutTime']))),
                        ]),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final participants = await _attendanceData;
                  exportToExcel(participants);
                },
                child: const Text('Xuất báo cáo Excel'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final participants = await _attendanceData;
                  exportToPDF(participants);
                },
                child: const Text('Xuất báo cáo PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
