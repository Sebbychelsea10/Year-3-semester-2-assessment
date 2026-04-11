import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/database_helper.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'insights_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart'; 

class HomeScreen extends StatefulWidget {

  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  List<Transaction> _transactions = [];

  double get totalBalance {

    double balance = 0;

    for (var tx in _transactions) {
      balance += tx.isIncome ? tx.amount : -tx.amount;
    }


    return balance;
  }

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {

    final data =
        await DatabaseHelper().getTransactions(widget.username);

    setState(() {

      _transactions = data.map((tx) => Transaction(

        title: tx['title'],

        amount: (tx['amount'] as num).toDouble(),

        category: tx['category'],

        isIncome: tx['isIncome'] == 1,

        date: DateTime.parse(tx['date']),

      )).toList();
    });
  }


  void addTransaction(Transaction transaction) async {

    await DatabaseHelper().insertTransaction({

      "username": widget.username,

      "title": transaction.title,

      "amount": transaction.amount,

      "category": transaction.category,

      "isIncome": transaction.isIncome ? 1 : 0,

      "date": transaction.date.toIso8601String(),

    }
    );

    loadTransactions();
  }

  //  delete button deletes from database
  void deleteTransaction(int index) async {

    final tx = _transactions[index];

    await DatabaseHelper().deleteTransaction(
      widget.username,
      tx.title,
      tx.amount,
      tx.date.toIso8601String(),
    );

    loadTransactions();
  }


  Widget buildMenuBox(
      BuildContext context, String title, Color color, Widget page) {

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );

      },

      child: Container(

        height: 120,

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final balance = totalBalance;

    return Scaffold(

      appBar: AppBar(

        title: Text('Dashboard - ${widget.username}'),

        actions: [

          // Settings Button added
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () {

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );

            },
          ),

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [

                    const Text(
                      "Current Balance",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "£${balance.toStringAsFixed(2)}",

                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                  ],
                ),
              ),
            ),


            const SizedBox(height: 25),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,

              children: [

                buildMenuBox(
                  context,
                  "Add Expense",
                  Colors.red,
                  ExpenseScreen(onAdd: addTransaction),
                ),

                buildMenuBox(
                  context,
                  "Add Income",
                  Colors.green,
                  IncomeScreen(onAdd: addTransaction),
                ),

                buildMenuBox(
                  context,
                  "Insights",
                  Colors.blue,
                  InsightsScreen(transactions: _transactions),
                ),

              ],
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(

              child: _transactions.isEmpty

                  ? const Center(
                      child: Text("No transactions yet"),
                    )

                  : ListView.builder(

                      itemCount: _transactions.length,

                      itemBuilder: (context, index) {

                        final tx = _transactions[index];

                        return Card(

                          child: ListTile(

                            leading: CircleAvatar(

                              backgroundColor:
                                  tx.isIncome
                                      ? Colors.green
                                      : Colors.red,

                              child: Icon(

                                tx.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,

                                color: Colors.white,
                              ),
                            ),

                            title: Text(tx.title),

                            subtitle: Text(tx.category),

                            // updated to show amount and delete button

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Text(
                                  "£${tx.amount.toStringAsFixed(2)}",

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: tx.isIncome
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () => deleteTransaction(index),
                                  
                                ),
                              ],
                            ),

                          ),
                        );
                      },
                    ),

            ),

          ],
        ),
      ),
    );
  }
}
