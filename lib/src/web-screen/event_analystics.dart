// ignore_for_file: library_private_types_in_public_api

import 'package:event_management/src/mobile_screen/event/attendance_list.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/spending_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventAnalyticsWebPage extends StatefulWidget {
  final int eventId;
  const EventAnalyticsWebPage({super.key, required this.eventId});

  @override
  _EventAnalyticsWebPageState createState() => _EventAnalyticsWebPageState();
}

class _EventAnalyticsWebPageState extends State<EventAnalyticsWebPage> {
  String eventName = '';
  String startDate = '';
  String endDate = '';
  String registered = '0';
  int checkIns = 0;
  String participationPercentage = '0.0';
  double noShowsPercentage = 0.0;
  Map<String, double> _incomeData = {};
  Map<String, double> _expenseData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _loadSpendingData();
  }

  double get _totalIncome => _incomeData.values.isEmpty
      ? 0
      : _incomeData.values.reduce((a, b) => a + b);

  double get _totalExpense => _expenseData.values.isEmpty
      ? 0
      : _expenseData.values.reduce((a, b) => a + b);

  Future<void> _loadSpendingData() async {
    try {
      final fetchedData = await fetchSpendings(widget.eventId);

      Map<String, double> incomeData = {};
      Map<String, double> expenseData = {};

      for (var item in fetchedData) {
        if (item['type'] == 'Income') {
          incomeData[item['category']] = item['amount'].toDouble();
        } else if (item['type'] == 'Expense') {
          expenseData[item['category']] = item['amount'].toDouble();
        }
      }

      setState(() {
        _incomeData = incomeData;
        _expenseData = expenseData;
      });
    } catch (e) {
      setState(() {});
      LoggerService.logger.e('Error loading data: $e');
    }
  }

  Future<void> _loadEventData() async {
    try {
      final eventData = await getEventData(widget.eventId);
      final stats = await getStats(widget.eventId);
      final attendanceStats = await getEventAttendanceStats(widget.eventId);

      setState(() {
        eventName = eventData['data']['name'];
        startDate = DateFormat('MMMM d, yyyy • h:mm a')
            .format(DateTime.parse(eventData['data']['startDate']));
        endDate = DateFormat('MMMM d, yyyy • h:mm a')
            .format(DateTime.parse(eventData['data']['endDate']));
        registered = stats['registered'].toString();
        checkIns = attendanceStats?['checkedInParticipants'] ?? 0;
        participationPercentage =
            attendanceStats?['participationPercentage']?.toString() ?? '0';
        final participationDouble =
            double.tryParse(participationPercentage) ?? 0.0;
        noShowsPercentage = 100.0 - participationDouble;

        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    width: 1200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatisticsCards(),
                        const SizedBox(height: 20),
                        _buildAttendanceRate(),
                        const SizedBox(height: 20),
                        _buildIncomeExpenseCards(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAttendanceRate() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Rate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (double.tryParse(participationPercentage) ?? 0.0) / 100,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              '$participationPercentage% attendance',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AttendanceReportPage(
                              eventId: widget.eventId,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Start Date: $startDate',
                style: const TextStyle(fontSize: 16)),
            Text('End Date: $endDate', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Total Registrations',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(registered,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Check-ins', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(checkIns.toString(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseCards() {
    return Column(
      children: [
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Income & Expenses',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBar('Income', _totalIncome, Colors.blue),
                const SizedBox(height: 16),
                _buildBar('Expense', _totalExpense, Colors.red),
                const SizedBox(height: 16),
                _buildBar(
                    'Profit',
                    _totalIncome - _totalExpense,
                    (_totalIncome - _totalExpense) >= 0
                        ? Colors.green
                        : Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value.abs() / _totalIncome.clamp(1, double.infinity),
          color: color,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Text('${formatCurrency(value)} VND',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(amount);
  }
}
