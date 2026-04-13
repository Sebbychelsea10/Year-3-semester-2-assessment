import 'dart:convert';

// This class represents a financial transaction (both income and expense)
class Transaction {

  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;

  // Constructor to create a new transaction
  Transaction({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });

  // Converts the object into a Map (used for database storage)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'category': category,
      // Date is converted to string so it can be stored properly
      'date': date.toIso8601String(),
    };
  }

  // Creates a Transaction object from a Map (used when retrieving from database)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      title: map['title'],
      amount: map['amount'],
      isIncome: map['isIncome'],
      category: map['category'],
      // Converts stored string back into DateTime
      date: DateTime.parse(map['date']),
    );
  }

  // Converts the object into JSON format (useful for APIs or storage)
  String toJson() => json.encode(toMap());

  // Creates a Transaction object from JSON data
  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}