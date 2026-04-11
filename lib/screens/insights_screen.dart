import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/transaction.dart';

class InsightsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const InsightsScreen({
    super.key,
    required this.transactions,
  }
  );

  double get totalIncome {
    return transactions
        .where((tx) => tx.isIncome)
        .fold(0, (sum, tx) => sum + tx.amount);
  }
  

  double get totalExpenses {
    return transactions
        .where((tx) => !tx.isIncome)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  Map<String, double> get expenseByCategory {
    final Map<String, double> data = {};

    for (var tx in transactions.where((t) => !t.isIncome)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }

    return data;
  }

  Widget buildSummaryCard(String title, double amount, Color color) {
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
                '£${amount.toStringAsFixed(2)}',
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
    final netBalance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: transactions.isEmpty
            ? const Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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
                          "Income", totalIncome, Colors.green),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                          "Expenses", totalExpenses, Colors.red),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                          "Balance",
                          netBalance,
                          netBalance >= 0
                              ? Colors.green
                              : Colors.red),
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

                  Expanded(
                    child: ListView(
                      children: expenseByCategory.entries.map((entry) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: const Icon(
                                Icons.category,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(entry.key),
                            trailing: Text(
                              '£${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}