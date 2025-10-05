// models/transaction.dart
class Transaction {
  final String id;
  final String name;
  final double money;
  final DateTime date;
  final TransactionType type;

  // 修改构造函数，优先使用传入的 id
  Transaction({
    String? id, // 接受可空的 id
    required this.name,
    required this.money,
    required this.date,
    required this.type,
  }) : id =
           id ??
           DateTime.now().millisecondsSinceEpoch
               .toString(); // 如果传入 id 为 null，则生成新的时间戳 id

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'money': money,
      'date': date.toIso8601String(), // 存储为 ISO 字符串
      'type': type.toString(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      name: map['name'],
      money: map['money'],
      date: DateTime.parse(map['date']), // 从字符串解析回 DateTime
      type: map['type'].toString().contains('income')
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}

enum TransactionType { income, expense }
