// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, unused_local_variable, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class WebAttendanceReportPage extends StatefulWidget {
  final int eventId;

  const WebAttendanceReportPage({super.key, required this.eventId});

  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<WebAttendanceReportPage> {
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
    final defaultSheetName = excel.sheets.keys.first;
    final sheet = excel[defaultSheetName];

    sheet.removeRow(0);

    // Set headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Name');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Email');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Check-In');
    sheet.cell(CellIndex.indexByString('D1')).value =
        TextCellValue('Check-Out');

    // Populate data
    for (int i = 0; i < participants.length; i++) {
      final participant = participants[i];
      sheet.cell(CellIndex.indexByString('A${i + 2}')).value =
          TextCellValue(participant['name'] ?? '');
      sheet.cell(CellIndex.indexByString('B${i + 2}')).value =
          TextCellValue(participant['email'] ?? '');
      sheet.cell(CellIndex.indexByString('C${i + 2}')).value =
          TextCellValue(formatDate(participant['checkInTime']));
      sheet.cell(CellIndex.indexByString('D${i + 2}')).value =
          TextCellValue(formatDate(participant['checkOutTime']));
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final blob = html.Blob([fileBytes], 'application/vnd.ms-excel');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.Url.revokeObjectUrl(url);
    }

    excel.sheets.clear();
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
                headers: ['Name', 'Email', 'Check-In', 'Check-Out'],
                data: participants.map((p) {
                  return [
                    p['name'] ?? '',
                    p['email'] ?? '',
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

    final fileBytes = await pdf.save();
    final blob = html.Blob([fileBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'Attendance_Report.pdf'
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Attendance Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance Details',
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
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Check-In')),
                        DataColumn(label: Text('Check-Out')),
                      ],
                      rows: List.generate(
                        participants.length,
                        (index) => DataRow(cells: [
                          DataCell(Text(participants[index]['name'] ?? '')),
                          DataCell(Text(participants[index]['email'] ?? '')),
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
                child: const Text('Export to Excel'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final participants = await _attendanceData;
                  exportToPDF(participants);
                },
                child: const Text('Export to PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
