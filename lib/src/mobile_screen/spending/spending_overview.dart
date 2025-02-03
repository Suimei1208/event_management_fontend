// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/service/spending_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:intl/intl.dart';

class SpendingOverviewPage extends StatefulWidget {
  final int eventId;

  const SpendingOverviewPage({super.key, required this.eventId});

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
          title: Text(S.of(context).add_income_spending),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab for selecting Income or Expense
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(S.of(context).spending),
                    selected: selectedType == "Expense",
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedType = "Expense");
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text(S.of(context).income),
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
                      ? S.of(context).spe_cate
                      : S.of(context).source,
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: S.of(context).amount,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel),
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
                    SnackBar(
                      content: Text(S.of(context).spending_warning),
                    ),
                  );
                }
              },
              child: const Text("OK"),
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
        title: Text(S.of(context).spending_mana),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.of(context).spending),
            Tab(text: S.of(context).income),
            Tab(text: S.of(context).overview),
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
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SpendingPieChart(
                            title: S.of(context).spending,
                            dataMap: _expenseData,
                            isExpense: true,
                          ),
                          SpendingPieChart(
                            title: S.of(context).income,
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
                    Text(
                        "${S.of(context).total_income}: ${formatCurrency(_totalIncome)}"),
                    const SizedBox(height: 8),
                    Text(
                        "${S.of(context).total_spending}: ${formatCurrency(_totalExpense)}"),
                    const SizedBox(height: 8),
                    Text(
                        "${S.of(context).remain}: ${formatCurrency(_remainingBalance)}"),
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
                    S.of(context).income,
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
                      return _buildTransactionCard(context, item);
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
                    S.of(context).spending,
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
                      return _buildTransactionCard(
                          context, item); // Add context parameter
                    },
                  ),
                ],
              ),
            ),

          // If no transactions, show message
          if (incomeItems.isEmpty && expenseItems.isEmpty)
            Center(
              child: Text(
                S.of(context).no_transactions,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build a transaction card
  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> item) {
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
                text:
                    "${S.of(context).amount}: ${formatCurrency(item['amount'])} | ",
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
