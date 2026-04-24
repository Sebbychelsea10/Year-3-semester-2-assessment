import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/setting_provider.dart';

// Screen used to add a new expense

class ExpenseScreen extends StatefulWidget {

   // Function passed from home screen to add a transaction
  
  final Function(Transaction) onAdd;

  const ExpenseScreen({super.key, required this.onAdd});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}


class _ExpenseScreenState extends State<ExpenseScreen> {
  // Controllers to get user input from text fields

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Transport",
    "Entertainment",
    "Shopping",
    "Bills",
    "Other"
  ];

  // NEW: track total entered expenses for quick prediction
  double predictedTotalAfter = 0;

  // This function runs when user presses "Save Expense"

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      return;
    }

    final settings = Provider.of<SettingProvider>(context, listen: false);

    // NEW: simulate overspending check (basic intelligent logic)
    double futureSpending = predictedTotalAfter + amount;

    if (futureSpending > settings.savingsAmount) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Warning ⚠️"),
          content: const Text(
              "This expense may exceed your available savings. Continue?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addTransaction(amount);
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
      return;
    }

    _addTransaction(amount);
  }

  // NEW: separated function to keep logic clean
  void _addTransaction(double amount) {

    // Create a new transaction object with the user input and pass it back to home screen
    final transaction = Transaction(
      title: _descriptionController.text,
      amount: amount,
      isIncome: false,
      category: _selectedCategory,
      date: DateTime.now(),
    );

    widget.onAdd(transaction);

    Navigator.pop(context);
  }

  // NEW: simple category intelligence (detect risky categories)
  bool isHighSpendingCategory(String category) {
    return category == "Shopping" || category == "Entertainment";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

             // Input for amount

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount (£)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  setState(() {
                    predictedTotalAfter = parsed;
                  });
                }
              },
            ),

            const SizedBox(height: 15),
            

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: _selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // NEW: show smart warning for risky categories
            if (isHighSpendingCategory(_selectedCategory))
              const Text(
                "⚠️ This category often leads to higher spending",
                style: TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Save Expense",
                  style: TextStyle(fontSize: 18),

                ),
              ),
            ),
          ],
        ),
        
      ),
    );
  }
}