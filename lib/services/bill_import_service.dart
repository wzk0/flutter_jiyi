import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:crypto/crypto.dart';

class ImportResult {
  final int successCount;
  final int duplicateCount;

  ImportResult(this.successCount, this.duplicateCount);
}

class BillImportService {
  static final BillImportService instance = BillImportService._init();
  BillImportService._init();

  Future<List<Transaction>> importWeChatBillFromBytes(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first]!;
      final List<Transaction> transactions = [];

      final rows = sheet.rows;

      bool isWeChat = false;
      for (int i = 0; i < rows.length && i < 20; i++) {
        final row = rows[i];
        for (var cell in row) {
          if (cell!.value?.toString().contains('微信') == true) {
            isWeChat = true;
            break;
          }
        }
        if (isWeChat) break;
      }

      if (!isWeChat) {
        return [];
      }

      for (int i = 17; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        if (row.length < 6) continue;

        final timeStr = row[0]!.value?.toString() ?? '';
        final transactionType = row[1]!.value?.toString() ?? '';
        final counterparty = row[2]!.value?.toString() ?? '';
        final commodity = row[3]!.value?.toString() ?? '';
        final incomeExpenseStr = row[4]!.value?.toString() ?? '';
        final amountStr = row[5]!.value?.toString() ?? '';

        if (timeStr.isEmpty || incomeExpenseStr.isEmpty || amountStr.isEmpty) {
          continue;
        }

        DateTime date;
        try {
          date = DateTime.parse(timeStr);
        } catch (e) {
          continue;
        }

        double money;
        try {
          final cleanAmountStr = amountStr.replaceAll('¥', '');
          money = double.parse(cleanAmountStr);
        } catch (e) {
          continue;
        }

        TransactionType type;
        if (incomeExpenseStr.contains('收入') ||
            incomeExpenseStr.contains('入账')) {
          type = TransactionType.income;
        } else if (incomeExpenseStr.contains('支出')) {
          type = TransactionType.expense;
        } else {
          type = TransactionType.expense;
        }

        String name = '${transactionType.trim()}-${counterparty.trim()}';
        if (commodity.isNotEmpty) {
          name += '($commodity)';
        }
        if (counterparty.isEmpty && commodity.isEmpty) {
          name = transactionType.trim();
        }

        final uniqueKey =
            '$timeStr-$money-$counterparty-$commodity-$incomeExpenseStr';
        final id = sha256.convert(utf8.encode(uniqueKey)).toString();

        final transaction = Transaction(
          id: id,
          name: name,
          money: money,
          date: date,
          type: type,
        );

        transactions.add(transaction);
      }

      return transactions;
    } catch (e) {
      throw Exception('导入微信账单失败: $e');
    }
  }

  Future<List<Transaction>> importWeChatBillFromContent(
    String csvContent,
  ) async {
    return [];
  }

  Future<List<Transaction>> importAlipayBillFromContent(
    String csvContent,
  ) async {
    try {
      final lines = LineSplitter().convert(csvContent);

      int dataStartIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('交易时间')) {
          dataStartIndex = i + 1;
          break;
        }
      }

      if (dataStartIndex == -1 || dataStartIndex >= lines.length) {
        throw Exception('未找到交易数据起始行 (找不到包含"交易时间"的标题行)');
      }

      final List<Transaction> transactions = [];
      for (int i = dataStartIndex; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) {
          continue;
        }

        final fields = _parseCsvLine(line);

        if (fields.length < 7) {
          continue;
        }

        final timeStr = fields[0];
        final transactionType = fields[1];
        final counterparty = fields[2];
        final commodity = fields[4];
        final incomeExpenseStr = fields[5];
        final amountStr = fields[6];

        if (timeStr.isEmpty || incomeExpenseStr.isEmpty || amountStr.isEmpty) {
          continue;
        }

        if (incomeExpenseStr.contains('不计收支')) {
          continue;
        }

        DateTime date;
        try {
          date = DateTime.parse(timeStr);
        } catch (e) {
          continue;
        }

        double money;
        try {
          money = double.parse(amountStr);
        } catch (e) {
          continue;
        }

        TransactionType type;
        if (incomeExpenseStr.contains('收入')) {
          type = TransactionType.income;
        } else if (incomeExpenseStr.contains('支出')) {
          type = TransactionType.expense;
        } else {
          type = TransactionType.expense;
        }

        String name = '${transactionType.trim()}-${counterparty.trim()}';
        if (commodity.isNotEmpty && commodity != '/') {
          name += '($commodity)';
        }
        if (counterparty.isEmpty && commodity.isEmpty) {
          name = transactionType.trim();
        }

        final uniqueKey =
            '$timeStr-$money-$counterparty-$commodity-$incomeExpenseStr';
        final id = sha256.convert(utf8.encode(uniqueKey)).toString();

        final transaction = Transaction(
          id: id,
          name: name,
          money: money,
          date: date,
          type: type,
        );

        transactions.add(transaction);
      }

      return transactions;
    } catch (e) {
      throw Exception('导入支付宝账单失败: $e');
    }
  }

  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    bool escaped = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (escaped) {
        buffer.write(char);
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    fields.add(buffer.toString());

    return fields
        .map((field) => field.trim().replaceAll(RegExp(r'^"|"$'), ''))
        .toList();
  }

  Future<ImportResult> batchInsertTransactions(
    List<Transaction> transactions,
  ) async {
    int successCount = 0;
    int duplicateCount = 0;

    for (var transaction in transactions) {
      final existing = await DatabaseService.instance.getTransactionById(
        transaction.id,
      );
      if (existing == null) {
        await DatabaseService.instance.insertTransaction(transaction);
        successCount++;
      } else {
        duplicateCount++;
      }
    }

    return ImportResult(successCount, duplicateCount);
  }
}
