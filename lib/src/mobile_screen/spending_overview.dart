// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:event_management/src/service/spending_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/models/events.dart';
import 'package:intl/intl.dart';

class SpendingOverviewPage extends StatefulWidget {
  final int eventId;
  final Event event;

  const SpendingOverviewPage(
      {super.key, required this.eventId, required this.event});

  @override
  _SpendingOverviewPageState createState() => _SpendingOverviewPageState();
}

class _SpendingOverviewPageState extends State<SpendingOverviewPage>
    with SingleTickerProviderStateMixin {
  Map<String, double> _incomeData = {};
  Map<String, double> _expenseData = {};
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  late TabController _tabController;

  double get _totalIncome => _incomeData.values.isEmpty
      ? 0
      : _incomeData.values.reduce((a, b) => a + b);

  double get _totalExpense => _expenseData.values.isEmpty
      ? 0
      : _expenseData.values.reduce((a, b) => a + b);

  double get _remainingBalance => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Updated to 3 tabs
    _loadSpendingData(widget.eventId);
  }

  Future<void> _reloadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSpendingData(widget.eventId);
  }

  Future<void> _loadSpendingData(int eventId) async {
    try {
      final fetchedData = await fetchSpendings(eventId);

      Map<String, double> incomeData = {};
      Map<String, double> expenseData = {};
      List<Map<String, dynamic>> history = [];

      for (var item in fetchedData) {
        if (item['type'] == 'Income') {
          incomeData[item['category']] = item['amount'].toDouble();
        } else if (item['type'] == 'Expense') {
          expenseData[item['category']] = item['amount'].toDouble();
        }

        // Store item in history
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
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      LoggerService.logger.e('Error loading data: $e');
    }
  }

  void _showAddSpendingDialog() {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String selectedType = "Expense"; // Default type is Expense

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Thêm thu/chi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab for selecting Income or Expense
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Chi tiêu"),
                    selected: selectedType == "Expense",
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedType = "Expense");
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Thu nhập"),
                    selected: selectedType == "Income",
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedType = "Income");
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Input fields
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: selectedType == "Expense"
                      ? "Danh mục chi tiêu"
                      : "Nguồn tiền",
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Số tiền"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                final category = categoryController.text.trim();
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0.0;
                if (category.isNotEmpty && amount > 0) {
                  // Call method with type and amount
                  _addOrUpdateSpending(category, amount, selectedType);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Danh mục không được để trống và số tiền > 0"),
                    ),
                  );
                }
              },
              child: const Text("Thêm"),
            ),
          ],
        ),
      ),
    );
  }

  void _addOrUpdateSpending(String category, double amount, String type) async {
    try {
      // Adjust the logic to send `type` to the backend
      await addSpending(widget.eventId, category, amount, type);

      // Reload data after successful addition
      await _reloadData();
    } catch (e) {
      LoggerService.logger.e("Failed to add $type: $e");
    }
  }

  void _deleteSpending(int id) async {
    try {
      // Delete the spending by id
      await deleteSpending(widget.eventId, id);

      // Reload data after successful deletion
      await _reloadData();
    } catch (e) {
      LoggerService.logger.e("Failed to delete spending: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý chi tiêu"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Chi tiêu"),
            Tab(text: "Thu nhập"),
            Tab(text: "Tổng quan"),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _reloadData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Text(
                      widget.event.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SpendingPieChart(
                            title: "Chi tiêu",
                            dataMap: _expenseData,
                            isExpense: true,
                          ),
                          SpendingPieChart(
                            title: "Thu nhập",
                            dataMap: _incomeData,
                            isExpense: false,
                          ),
                          HistoryOverviewTab(
                            // History tab to show all transactions
                            history: _history,
                            onDelete: _deleteSpending,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Tổng thu nhập: ${formatCurrency(_totalIncome)}"),
                    const SizedBox(height: 8),
                    Text("Tổng chi tiêu: ${formatCurrency(_totalExpense)}"),
                    const SizedBox(height: 8),
                    Text("Số dư còn lại: ${formatCurrency(_remainingBalance)}"),
                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addIncome",
            onPressed: () => _showAddSpendingDialog(),
            tooltip: "Thêm thu nhập",
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(amount)} VND";
  }
}

class HistoryOverviewTab extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final Function(int) onDelete;

  const HistoryOverviewTab({
    super.key,
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return history.isEmpty
        ? const Center(
            child: Text("Không có giao dịch nào",
                style: TextStyle(fontSize: 16, color: Colors.grey)))
        : ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16), // Add rounded corners
                ),
                elevation: 4, // Slight shadow for the card
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12), // Modern padding
                  leading: Icon(
                    item['type'] == 'Income'
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    color: item['type'] == 'Income' ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    item['category'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Số tiền: ${formatCurrency(item['amount'])} | ${item['type']}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => onDelete(item['id']),
                  ),
                ),
              );
            },
          );
  }

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(amount)} VND";
  }
}

class SpendingPieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final String title;
  final bool isExpense; // True for Expense, False for Income

  const SpendingPieChart({
    super.key,
    required this.dataMap,
    required this.title,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _buildPieChartSections(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        _buildLegend(dataMap), // Move the legend here inside the tab
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    // Generate unique colors based on the length of the dataMap
    final colors = List.generate(dataMap.length, (index) {
      return Color(0xFF000000 + index * 123456);
    });

    int colorIndex = 10;

    return dataMap.entries.map((entry) {
      return PieChartSectionData(
        color: colors[colorIndex++ % colors.length],
        value: entry.value,
        title:
            "${(entry.value / dataMap.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // Moved the _buildLegend function here
  Widget _buildLegend(Map<String, double> dataMap) {
    final totalAmount =
        dataMap.values.isEmpty ? 0 : dataMap.values.reduce((a, b) => a + b);

    // Generate unique colors based on the length of the dataMap
    final colors = List.generate(dataMap.length, (index) {
      return Color(0xFF000000 + index * 111111);
    });

    int colorIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dataMap.entries.map((entry) {
        final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);
        final amount =
            formatCurrency(entry.value); // Format the amount in currency

        // Use the color from the pie chart sections
        final sectionColor = colors[colorIndex++ % colors.length];

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: sectionColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text("${entry.key}: $amount ($percentage%)"),
          ],
        );
      }).toList(),
    );
  }

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(amount)} VND";
  }
}
