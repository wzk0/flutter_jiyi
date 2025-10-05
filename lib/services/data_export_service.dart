import 'dart:convert';
import 'dart:typed_data';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:archive/archive.dart';

class DataExportService {
  static final DataExportService instance = DataExportService._();

  DataExportService._();

  Future<String> exportDataToString() async {
    try {
      final transactions = await DatabaseService.instance.getTransactions();

      final List<Map<String, dynamic>> dataList = transactions.map((t) {
        return {
          'id': t.id,
          'name': t.name,
          'money': t.money,
          'date': t.date.toIso8601String(),
          'type': t.type.toString(),
        };
      }).toList();

      final jsonString = jsonEncode(dataList);

      final encryptedString = base64Encode(utf8.encode(jsonString));

      final compressedData = _compressString(encryptedString);
      if (compressedData == null) {
        throw Exception("压缩数据失败");
      }

      final encodedString = base64Encode(compressedData);

      return encodedString;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> importDataFromString(String encodedString) async {
    try {
      final compressedData = base64Decode(encodedString);

      final decompressedString = _decompressString(compressedData);
      if (decompressedString == null) {
        throw Exception("解压缩数据失败");
      }

      final jsonString = utf8.decode(base64Decode(decompressedString));

      final List<dynamic> decodedList = jsonDecode(jsonString);
      final List<Transaction> transactions = decodedList
          .map(
            (json) => Transaction(
              id: json['id'],
              name: json['name'],
              money: json['money'],
              date: DateTime.parse(json['date']),
              type: json['type'].toString().contains('income')
                  ? TransactionType.income
                  : TransactionType.expense,
            ),
          )
          .toList();

      int importedCount = 0;
      for (var transaction in transactions) {
        final existing = await DatabaseService.instance.getTransactionById(
          transaction.id,
        );
        if (existing == null) {
          await DatabaseService.instance.insertTransaction(transaction);
          importedCount++;
        } else {
          await DatabaseService.instance.updateTransaction(transaction);
          importedCount++;
        }
      }

      return importedCount > 0;
    } catch (e) {
      rethrow;
    }
  }

  Uint8List? _compressString(String str) {
    try {
      final encoder = ZipEncoder();
      final archive = Archive();
      final contentBytes = utf8.encode(str);
      final archiveFile = ArchiveFile(
        'data.txt',
        contentBytes.length,
        contentBytes,
      );
      archive.addFile(archiveFile);
      final compressedBytesNullable = encoder.encode(archive);
      if (compressedBytesNullable != null) {
        return Uint8List.fromList(compressedBytesNullable);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String? _decompressString(Uint8List compressedData) {
    try {
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(compressedData);
      final file = archive.findFile('data.txt');
      if (file != null) {
        if (file.content is List<int>) {
          return utf8.decode(file.content as List<int>);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
