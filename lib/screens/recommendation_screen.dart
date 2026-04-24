import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/setting_provider.dart';

class RecommendationScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const RecommendationScreen({
    super.key,
    required this.transactions,
  });

  // total income
  double get totalIncome {
    return transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // total expenses
  double get totalExpenses {
    return transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // savings rate (% of income saved)
  double get savingsRate {
    if (totalIncome == 0) return 0;
    return ((totalIncome - totalExpenses) / totalIncome);
  }

  // recommended monthly savings (smart logic)
  double get recommendedSavings {
    double base = totalIncome * 0.2; // 20% rule

    // adjust based on behaviour
    if (savingsRate < 0.1) {
      return base * 0.5; // struggling → reduce target
    } else if (savingsRate > 0.3) {
      return base * 1.5; // doing well → push harder
    }

    return base;
  }

  // risk level
  String get riskLevel {
    if (savingsRate < 0.1) return "High Risk";
    if (savingsRate < 0.2) return "Medium Risk";
    return "Low Risk";
  }

  // smart advice generator
  String get advice {
    if (totalIncome == 0) {
      return "No income data available.";
    }

    if (savingsRate < 0) {
      return "You are spending more than you earn. Immediate action required.";
    }

    if (savingsRate < 0.1) {
      return "Try reducing non-essential expenses like shopping or entertainment.";
    }

    if (savingsRate < 0.2) {
      return "You're doing okay, but could improve savings slightly.";
    }

    return "Great job! You are saving effectively. Consider investing.";
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Recommendations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: transactions.isEmpty
            ? const Center(child: Text("No data available"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Financial Health Analysis",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: ListTile(
                      title: const Text("Savings Rate"),
                      trailing: Text(
                        "${(savingsRate * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text("Risk Level"),
                      trailing: Text(
                        riskLevel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: riskLevel == "High Risk"
                              ? Colors.red
                              : riskLevel == "Medium Risk"
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Recommended Monthly Savings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: ListTile(
                      title: const Text("Suggested Amount"),
                      trailing: Text(
                        "${settings.currency}${recommendedSavings.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Advice",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        advice,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}