import 'package:flutter/material.dart';
import '../models/transaction.dart';

class ExpenseScreen extends StatefulWidget {
  
  final Function(Transaction) onAdd;

  const ExpenseScreen({super.key, required this.onAdd});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}


class _ExpenseScreenState extends State<ExpenseScreen> {
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

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      return;
    }

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

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount (£)",
                border: OutlineInputBorder(),
              ),
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