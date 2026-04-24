import 'package:flutter/material.dart';
import '../models/transaction.dart';

class IncomeScreen extends StatefulWidget {
  final Function(Transaction) onAdd;

  const IncomeScreen({super.key, required this.onAdd});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {

  // Controllers to get user input from text fields
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // Default values for category and date
  String _selectedCategory = 'Student Loan';
  DateTime _selectedDate = DateTime.now();

// List of income categories
  final List<String> _categories = [
    'Student Loan',
    'Part-time Job',
    'Scholarship',
    'Family',
    'Other',
  ];

  // NEW: predicted yearly income
  double get predictedYearlyIncome {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount * 12;
  }

  // NEW: recommended savings (20% rule)
  double get recommendedSavings {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount * 0.2;
  }

  // NEW: financial health indicator
  String get financialHealth {
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount < 500) return "Low Income";
    if (amount < 1500) return "Moderate Income";
    return "Strong Income";
  }

// Handles saving income when user presses "Save Income"
  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) {
      return;
    }
// Creates a new Transaction object and sends it back to HomeScreen
    widget.onAdd(
      Transaction(
        title: title,
        amount: amount,
        isIncome: true,
        category: _selectedCategory,
        date: _selectedDate,
      ),
    );

    Navigator.pop(context); // go back to previous screen after saving
  }

  // Opens date picker so user can choose a custom date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    // Only update if user actually selects a date
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

 // Input for income title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Income Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),
// Input for amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (£)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {}); // 🔥 updates predictions live
              },
            ),

            const SizedBox(height: 15),

            // NEW: Advanced income insights
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Yearly Projection"),
                        Text("£${predictedYearlyIncome.toStringAsFixed(2)}"),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Suggested Savings (20%)"),
                        Text("£${recommendedSavings.toStringAsFixed(2)}"),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Financial Health"),
                        Text(
                          financialHealth,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: financialHealth == "Low Income"
                                ? Colors.red
                                : financialHealth == "Moderate Income"
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Dropdown to choose category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    // Button to open date picker
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Save Income',
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