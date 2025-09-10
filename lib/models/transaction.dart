class Transaction {
  final String id;
  final String name;
  final double money;
  final DateTime date; // 改为DateTime类型
  final TransactionType type;

  Transaction({
    String? id,
    required this.name,
    required this.money,
    required this.date,
    required this.type,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // 转换为Map（用于SQLite存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'money': money,
      'date': date.toIso8601String(), // 转换为字符串存储
      'type': type.toString(),
    };
  }

  // 从Map创建对象（用于SQLite读取）
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      name: map['name'],
      money: map['money'],
      date: DateTime.parse(map['date']), // 从字符串转换回DateTime
      type: map['type'].toString().contains('income')
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}

enum TransactionType { income, expense }
