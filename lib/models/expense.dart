// This class represents a single expense entry in the app
class Expense {
  final double amount;
  final String category;
  final DateTime date;
  final String? note;


// Constructor used to create a new Expense object
  Expense({
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  }

  );
  
}