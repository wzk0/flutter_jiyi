class Transaction {
  //final String id;
  final String name;
  final double money;
  final String date;
  final TransactionType type;
  //final String category;
  //final DateTime date;

  Transaction({
    required this.date,
    required this.name,
    required this.money,
    required this.type,
  });
}

enum TransactionType { income, expense }
