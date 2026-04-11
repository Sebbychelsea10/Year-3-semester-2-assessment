class Expense {
  final double amount;
  final String category;
  final DateTime date;
  final String? note;


  Expense({
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  }

  );
  
}