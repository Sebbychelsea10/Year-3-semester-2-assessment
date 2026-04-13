import 'package:flutter/material.dart';
import '../models/transaction.dart';

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

  // This function runs when user presses "Save Expense"

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      return;
    }


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