// ignore_for_file: library_private_types_in_public_api

import 'package:event_management/src/mobile_screen/event/attendance_list.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/spending_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventAnalyticsPage extends StatefulWidget {
  final int eventId;
  const EventAnalyticsPage({super.key, required this.eventId});

  @override
  _EventAnalyticsPageState createState() => _EventAnalyticsPageState();
}

class _EventAnalyticsPageState extends State<EventAnalyticsPage> {
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
      List<Map<String, dynamic>> history = [];

      for (var item in fetchedData) {
        if (item['type'] == 'Income') {
          incomeData[item['category']] = item['amount'].toDouble();
        } else if (item['type'] == 'Expense') {
          expenseData[item['category']] = item['amount'].toDouble();
        }

        history.add({
          'id': item['id'],
          'type': item['type'],
          'category': item['category'],
          'amount': item['amount'].toDouble(),
          'date': item['date'],
        });
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
      appBar: AppBar(
        title: const Text('Event Analytics'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildStatistics(),
                  const SizedBox(height: 20),
                  _buildAttendanceRate(
                    participationPercentage,
                    noShowsPercentage,
                  ),
                  const SizedBox(height: 20),
                  _buildProfit()
                ],
              ),
            ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              eventName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              startDate,
              style: const TextStyle(color: Colors.grey),
            ),
            const Text(
              "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              endDate,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('Total Registrations',
                        style: TextStyle(fontSize: 18)),
                    Text(registered,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Check-ins', style: TextStyle(fontSize: 18)),
                    Text(checkIns.toString(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRate(String participationPercentage, double noShows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Attendance Rate',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Attendance - $participationPercentage%',
                        style: const TextStyle(color: Colors.blue)),
                  ],
                ),
                Column(
                  children: [
                    Text('No-show-up - ${noShows.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(amount);
  }

  Widget _buildProfit() {
    return Column(
      children: [
        _buildBar(
            'Income', _totalIncome, formatCurrency(_totalIncome), Colors.blue),
        const SizedBox(height: 12),
        _buildBar('Expense', _totalExpense, formatCurrency(_totalExpense),
            Colors.red),
        const SizedBox(height: 12),
        _buildBar(
          'Profit',
          _totalIncome - _totalExpense,
          formatCurrency(_totalIncome - _totalExpense),
          (_totalIncome - _totalExpense) >= 0 ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildBar(
      String label, double value, String displayValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value.abs() / _totalIncome.clamp(1, double.infinity),
          color: color,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 4),
        Text('$displayValue VND',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
