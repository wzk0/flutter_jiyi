class Transaction {
  final String id;
  final String name;
  final double money;
  final DateTime date;
  final TransactionType type;

  Transaction({
    String? id,
    required this.name,
    required this.money,
    required this.date,
    required this.type,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'money': money,
      'date': date.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      name: map['name'],
      money: map['money'],
      date: DateTime.parse(map['date']),
      type: map['type'].toString().contains('income')
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}

enum TransactionType { income, expense }
