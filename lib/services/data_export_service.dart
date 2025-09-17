// services/data_export_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:archive/archive.dart';

class DataExportService {
  static final DataExportService instance = DataExportService._();

  DataExportService._();

  // 导出数据为加密字符串
  Future<String> exportDataToString() async {
    try {
      // 1. 获取所有交易数据
      final transactions = await DatabaseService.instance.getTransactions();

      // 2. 转换为可序列化的Map列表
      final List<Map<String, dynamic>> dataList = transactions.map((t) {
        return {
          'id': t.id,
          'name': t.name,
          'money': t.money,
          'date': t.date.toIso8601String(),
          'type': t.type == TransactionType.income ? 'income' : 'expense',
        };
      }).toList();

      // 3. 转换为JSON字符串
      final jsonString = jsonEncode(dataList);

      // 4. 压缩数据
      final compressedData = _compressString(jsonString);

      // 5. 转换为Base64字符串
      final base64String = base64Encode(compressedData);

      return base64String;
    } catch (e) {
      throw Exception('导出数据失败: $e');
    }
  }

  // 从字符串导入数据
  Future<bool> importDataFromString(String dataString) async {
    try {
      // 1. Base64解码
      final compressedData = base64Decode(dataString);

      // 2. 解压缩
      final jsonString = _decompressString(compressedData);

      // 3. 解析JSON
      final List<dynamic> dataList = jsonDecode(jsonString);

      // 4. 转换为Transaction对象并保存到数据库
      int importedCount = 0;
      for (var item in dataList) {
        final transaction = Transaction(
          id: item['id'],
          name: item['name'],
          money: (item['money'] as num).toDouble(),
          date: DateTime.parse(item['date']),
          type: item['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
        );

        // 检查是否已存在该ID的记录
        final existing = await DatabaseService.instance.getTransactionById(
          transaction.id,
        );
        if (existing == null) {
          // 如果不存在则插入新记录
          await DatabaseService.instance.insertTransaction(transaction);
          importedCount++;
        } else {
          // 如果存在则更新记录
          await DatabaseService.instance.updateTransaction(transaction);
          importedCount++;
        }
      }

      debugPrint('成功导入 $importedCount 条记录');
      return true;
    } catch (e) {
      throw Exception('导入数据失败: $e');
    }
  }

  // 压缩字符串
  Uint8List _compressString(String data) {
    final encoder = GZipEncoder();
    final bytes = utf8.encode(data);
    return Uint8List.fromList(encoder.encode(bytes));
  }

  // 解压缩字符串
  String _decompressString(Uint8List compressedData) {
    final decoder = GZipDecoder();
    final decompressed = decoder.decodeBytes(compressedData);
    return utf8.decode(decompressed);
  }
}
