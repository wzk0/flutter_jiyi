import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/bill_import_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';

class BillImportDialog extends StatefulWidget {
  final Function(List<Transaction>, int, int) onImport;

  const BillImportDialog({super.key, required this.onImport});

  @override
  State<BillImportDialog> createState() => _BillImportDialogState();
}

class _BillImportDialogState extends State<BillImportDialog> {
  List<Transaction> _parsedTransactions = [];
  List<bool> _selectedForImport = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _selectedFileName;
  bool _isZipFile = false;
  String _zipPassword = '';
  String? _sourceType;

  Future<void> _selectAndParseFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _selectedFileName = null;
      _isZipFile = false;
      _zipPassword = '';
      _sourceType = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'zip'],
        dialogTitle: '请选择账单文件 (Excel 或 ZIP)',
      );

      if (result != null && result.files.single.path != null) {
        _selectedFileName = result.files.single.name;
        File file = File(result.files.single.path!);

        String fileExtension = _getFileExtension(_selectedFileName!);
        Uint8List fileBytes = await file.readAsBytes();

        if (fileExtension.toLowerCase() == 'zip') {
          _isZipFile = true;
          await _showPasswordDialog(fileBytes);
        } else if (fileExtension.toLowerCase() == 'xlsx') {
          await _parseExcelFile(fileBytes);
        } else {
          throw Exception('不支持的文件格式: $fileExtension');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '解析文件失败: $e';
      });
    }
  }

  String _getFileExtension(String fileName) {
    int lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
      return fileName.substring(lastDotIndex + 1);
    }
    return '';
  }

  Future<void> _showPasswordDialog(Uint8List zipBytes) async {
    final passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('输入密码'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: '请输入ZIP密码'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            FilledButton(
              child: const Text('确定'),
              onPressed: () async {
                _zipPassword = passwordController.text;
                Navigator.of(context).pop();
                try {
                  await _extractAndParseZip(zipBytes, _zipPassword);
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = '解压或解析失败: $e';
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _extractAndParseZip(Uint8List zipBytes, String password) async {
    try {
      Archive archive;
      try {
        archive = ZipDecoder().decodeBytes(zipBytes, password: password);
      } catch (e) {
        throw Exception('ZIP解压失败, 可能是密码错误: $e');
      }

      ArchiveFile? csvFile = _findCsvFile(archive);

      if (csvFile == null) {
        throw Exception('ZIP文件中未找到CSV文件');
      }

      final csvContentBytes = csvFile.content as List<int>;
      String csvContentString;

      try {
        csvContentString = gbk.decode(Uint8List.fromList(csvContentBytes));
      } catch (gbkError) {
        debugPrint("gbk2utf8 解码失败: $gbkError, 尝试 UTF-8...");
        try {
          csvContentString = utf8.decode(csvContentBytes);
          debugPrint("使用 UTF-8 成功解码 CSV 文件");
        } catch (utf8Error) {
          debugPrint("UTF-8 解码也失败: $utf8Error");
          throw Exception('无法解码CSV文件内容, 请检查文件编码 (尝试了 GBK 和 UTF-8)');
        }
      }

      if (csvContentString.contains('支付宝')) {
        _sourceType = '支付宝';
        final transactions = await BillImportService.instance
            .importAlipayBillFromContent(csvContentString);
        _parsedTransactions = transactions;
        _selectedForImport = List.generate(
          transactions.length,
          (index) => true,
        );
        setState(() {
          _isLoading = false;
        });
      } else if (csvContentString.contains('微信')) {
        _sourceType = '微信';
        final transactions = await BillImportService.instance
            .importWeChatBillFromContent(csvContentString);
        _parsedTransactions = transactions;
        _selectedForImport = List.generate(
          transactions.length,
          (index) => true,
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('CSV文件内容无法识别 (既不包含"支付宝"也不包含"微信")');
      }
    } catch (e) {
      rethrow;
    }
  }

  ArchiveFile? _findCsvFile(Archive archive) {
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (file.name.toLowerCase().endsWith('.csv') &&
          !file.name.contains('__MACOSX')) {
        debugPrint("在 ZIP 中找到 CSV 文件: ${file.name}");
        return file;
      }
    }
    return null;
  }

  Future<void> _parseExcelFile(Uint8List fileBytes) async {
    try {
      final transactions = await BillImportService.instance
          .importWeChatBillFromBytes(fileBytes);
      if (transactions.isEmpty) {
        throw Exception('无法识别的Excel文件格式, 或非微信账单');
      }
      _sourceType = '微信';
      _parsedTransactions = transactions;
      _selectedForImport = List.generate(transactions.length, (index) => true);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  String _getTransactionTypeString(TransactionType type) {
    return type == TransactionType.income ? '收入' : '支出';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入账单'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Text(_errorMessage)
          : _parsedTransactions.isEmpty
          ? Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_selectedFileName != null) ...[
                  Text('已选择: $_selectedFileName', textAlign: TextAlign.center),
                  if (_isZipFile && _zipPassword.isNotEmpty) ...[
                    Text(
                      '已输入密码',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ],
                FilledButton.tonal(
                  onPressed: _selectAndParseFile,
                  child: Text('选择 支付宝/微信账单文件'),
                ),
                Text(
                  '- 支付宝导出的账单为zip格式, 可直接选择导入; 微信为xlsx格式. 选择账单文件后, 记易会自行判断账单来自哪个平台, 并进行分析. 分析完成后您可选择想导入的账目.\n\n- 微信导出账单的方式为: 我 -> 服务 -> 钱包 -> 右上角账单 -> 右上角三点 -> 下载账单 -> 用于个人对账 -> 接收方式为微信 -> 下载xlsx文件即可. \n\n- 支付宝导出账单的方式为: 我的 -> 账单 -> 右上角三点 -> 开具交易流水证明 -> 用于个人对账 -> 发送至邮箱后从邮箱下载zip文件即可(在支付宝首页 -> 最近消息中查看解压密码).',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('预览数据 (勾选要导入的项目):'),
                  const SizedBox(height: 10),
                  if (_selectedFileName != null) ...[
                    Text(
                      '$_selectedFileName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    if (_sourceType != null) ...[
                      Text(
                        '(可能来源: $_sourceType)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                  ],
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _parsedTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _parsedTransactions[index];
                        return CheckboxListTile(
                          title: Text(
                            '${transaction.name} - ¥ ${transaction.money.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            '${transaction.date} (${_getTransactionTypeString(transaction.type)})',
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _selectedForImport[index],
                          onChanged: (bool? newValue) {
                            if (newValue == null) return;
                            setState(() {
                              _selectedForImport[index] = newValue;
                            });
                          },
                          dense: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      actions: _parsedTransactions.isNotEmpty
          ? [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  final selectedTransactions = <Transaction>[];
                  for (int i = 0; i < _parsedTransactions.length; i++) {
                    if (_selectedForImport[i]) {
                      selectedTransactions.add(_parsedTransactions[i]);
                    }
                  }
                  widget.onImport(
                    selectedTransactions,
                    selectedTransactions.length,
                    0,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('导入'),
              ),
            ]
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('关闭'),
              ),
            ],
    );
  }
}
