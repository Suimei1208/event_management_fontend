// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:event_management/src/service/spending_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:intl/intl.dart';

class WebSpendingOverviewPage extends StatefulWidget {
  final int eventId;
  static const routeName = "/home/detail-event/spending";
  const WebSpendingOverviewPage({super.key, required this.eventId});

  @override
  _SpendingOverviewPageState createState() => _SpendingOverviewPageState();
}

class _SpendingOverviewPageState extends State<WebSpendingOverviewPage>
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
    _tabController = TabController(length: 3, vsync: this);
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
    String selectedType = "Expense";

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
      appBar: const CustomAppBar(),
      body: Row(
        children: [
          // Sidebar with icons and text
          NavigationRail(
            selectedIndex: _tabController.index,
            onDestinationSelected: (index) {
              _tabController.animateTo(index);
              setState(() {
                index = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white, // Set background color for rail
            selectedLabelTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Set color for selected label
            ),
            unselectedLabelTextStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey, // Set color for unselected label
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.blue, // Set color for selected icon
              size: 30, // Adjust icon size when selected
            ),
            unselectedIconTheme: const IconThemeData(
              color: Colors.grey, // Set color for unselected icon
              size: 24, // Adjust icon size when unselected
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.remove_circle_outline),
                label: Text("Chi tiêu"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_circle_outline),
                label: Text("Thu nhập"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pie_chart),
                label: Text("Tổng quan"),
              ),
            ],
          ),
          // Main content area
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reloadData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Tổng quan sự kiện",
                            style: Theme.of(context).textTheme.titleLarge,
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
                                  history: _history,
                                  onDelete: _deleteSpending,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Tổng thu nhập: ${formatCurrency(_totalIncome)}",
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tổng chi tiêu: ${formatCurrency(_totalExpense)}",
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Số dư còn lại: ${formatCurrency(_remainingBalance)}",
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          // Add Button
                          ElevatedButton.icon(
                            onPressed: _showAddSpendingDialog,
                            icon: const Icon(Icons.add),
                            label: const Text("Thêm thu/chi"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
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
    // Separate income and expenses
    final incomeItems =
        history.where((item) => item['type'] == 'Income').toList();
    final expenseItems =
        history.where((item) => item['type'] == 'Expense').toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (incomeItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Thu nhập",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: incomeItems.length,
                    itemBuilder: (context, index) {
                      final item = incomeItems[index];
                      return _buildTransactionCard(item);
                    },
                  ),
                ],
              ),
            ),

          if (expenseItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chi tiêu",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenseItems.length,
                    itemBuilder: (context, index) {
                      final item = expenseItems[index];
                      return _buildTransactionCard(item);
                    },
                  ),
                ],
              ),
            ),

          // If no transactions, show message
          if (incomeItems.isEmpty && expenseItems.isEmpty)
            const Center(
              child: Text(
                "Không có giao dịch nào",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build a transaction card
  Widget _buildTransactionCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      elevation: 4, // Shadow for the card
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(
          item['type'] == 'Income'
              ? Icons.add_circle_outline
              : Icons.remove_circle_outline,
          color: item['type'] == 'Income' ? Colors.green : Colors.red,
        ),
        title: Text(
          item['category'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Số tiền: ${formatCurrency(item['amount'])} | ",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              TextSpan(
                text: item['type'],
                style: TextStyle(
                  fontSize: 14,
                  color: item['type'] == 'Income' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => onDelete(item['id']),
        ),
      ),
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
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
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
        _buildLegend(dataMap),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    // Generate a list of colors once and use it for both the pie chart and legend
    final colors = List.generate(dataMap.length, (index) {
      return Color(0xFF000000 + index * 171717);
    });

    int colorIndex = 1; // Start at index 0 for the color list

    return dataMap.entries.map((entry) {
      return PieChartSectionData(
        color:
            colors[colorIndex++ % colors.length], // Use the color from the list
        value: entry.value,
        title:
            "${(entry.value / dataMap.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%",
        radius: 100,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> dataMap) {
    final totalAmount =
        dataMap.values.isEmpty ? 0 : dataMap.values.reduce((a, b) => a + b);

    // Generate the colors list once here as well
    final colors = List.generate(dataMap.length, (index) {
      return Color(0xFF000000 + index * 171717);
    });

    int colorIndex = 1; // Start at index 0 for the color list

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dataMap.entries.map((entry) {
        final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);
        final amount = formatCurrency(entry.value);

        final sectionColor =
            colors[colorIndex++ % colors.length]; // Use the same color

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
