import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/transaction.dart';
import '../providers/setting_provider.dart';

class InsightsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const InsightsScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {

  // NEW: selected filter range
  String selectedRange = "All";

  // NEW: filtered transactions based on selected range
  List<Transaction> get filteredTransactions {
    DateTime now = DateTime.now();

    if (selectedRange == "7 Days") {
      return widget.transactions.where((tx) =>
          tx.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
    }

    if (selectedRange == "30 Days") {
      return widget.transactions.where((tx) =>
          tx.date.isAfter(now.subtract(const Duration(days: 30)))).toList();
    }

    if (selectedRange == "3 Months") {
      return widget.transactions.where((tx) =>
          tx.date.isAfter(now.subtract(const Duration(days: 90)))).toList();
    }

    return widget.transactions;
  }

  // calculates total income
  double get totalIncome {
    return filteredTransactions
        .where((tx) => tx.isIncome)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  // calculates total expenses
  double get totalExpenses {
    return filteredTransactions
        .where((tx) => !tx.isIncome)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  // groups expenses by category (used for pie chart)
  Map<String, double> get expenseByCategory {
    final Map<String, double> data = {};

    for (var tx in filteredTransactions.where((t) => !t.isIncome)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }

    return data;
  }

  // NEW: groups savings by month (YYYY-MM)
  Map<String, double> getMonthlySavings(List<Map<String, dynamic>> history) {
    final Map<String, double> data = {};

    for (var item in history) {
      final date = DateTime.parse(item["date"]);
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";

      data[key] = (data[key] ?? 0) + item["amount"];
    }

    return data;
  }

  // NEW: average daily expense
  double get averageDailyExpense {
    if (filteredTransactions.isEmpty) return 0;

    final expenses = filteredTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    int days = filteredTransactions.length;
    return days == 0 ? 0 : expenses / days;
  }

  // NEW: predicted monthly expense (30 days)
  double get predictedMonthlyExpense {
    return averageDailyExpense * 30;
  }

  // NEW: predicted savings (income - predicted expenses)
  double get predictedSavings {
    return totalIncome - predictedMonthlyExpense;
  }

  // reusable card for income / expense / balance
  Widget buildSummaryCard(String title, double amount, Color color, String currency) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$currency${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<SettingProvider>(context);
    final monthlySavings = getMonthlySavings(settings.savingsHistory);

    final netBalance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: widget.transactions.isEmpty
            ? const Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : SingleChildScrollView( // ✅ FIX overflow + allow scrolling
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // NEW: filter dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRange,
                      items: ["All", "7 Days", "30 Days", "3 Months"]
                          .map((range) => DropdownMenuItem(
                                value: range,
                                child: Text(range),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRange = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Filter by time",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Financial Overview",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        buildSummaryCard(
                            "Income", totalIncome, Colors.green, settings.currency),
                        const SizedBox(width: 10),
                        buildSummaryCard(
                            "Expenses", totalExpenses, Colors.red, settings.currency),
                        const SizedBox(width: 10),
                        buildSummaryCard(
                            "Balance",
                            netBalance,
                            netBalance >= 0 ? Colors.green : Colors.red,
                            settings.currency),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Spending Breakdown',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 15),

                    PieChart(
                      dataMap: expenseByCategory.isEmpty
                          ? {'No Data': 1}
                          : expenseByCategory,
                      chartType: ChartType.disc,
                      chartRadius:
                          MediaQuery.of(context).size.width / 2.2,
                      legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.bottom,
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        decimalPlaces: 1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Expenses by Category",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    ...expenseByCategory.entries.map((entry) {
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Icon(
                              Icons.category,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(entry.key),
                          trailing: Text(
                            '${settings.currency}${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // NEW: Monthly savings section
                    const Text(
                      "Monthly Savings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...monthlySavings.entries.map((entry) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.savings),
                          title: Text(entry.key),
                          trailing: Text(
                            '${settings.currency}${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // NEW: Prediction section
                    const Text(
                      "Spending Prediction",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Card(
                      child: ListTile(
                        title: const Text("Predicted Monthly Expense"),
                        trailing: Text(
                          '${settings.currency}${predictedMonthlyExpense.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Card(
                      child: ListTile(
                        title: const Text("Predicted Savings"),
                        trailing: Text(
                          '${settings.currency}${predictedSavings.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: predictedSavings >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
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