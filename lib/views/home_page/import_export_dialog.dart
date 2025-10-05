import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/services/data_export_service.dart';

class ImportExportDialog extends StatefulWidget {
  const ImportExportDialog({super.key});

  @override
  State<ImportExportDialog> createState() => _ImportExportDialogState();
}

class _ImportExportDialogState extends State<ImportExportDialog> {
  String _exportData = '';
  String _importData = '';
  bool _isExporting = false;
  bool _isImporting = false;
  String _message = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('数据管理'),
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('导出数据'),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮导出所有账目数据为加密字符串',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton.icon(
                onPressed: _exportData.isEmpty ? _exportDataFunc : null,
                icon: _isExporting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.upload, size: 16),
                label: Text(_isExporting ? '导出中...' : '导出数据'),
              ),
            ),
            if (_exportData.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '导出成功!请复制下方字符串保存：',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  _exportData,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: OutlinedButton(
                  onPressed: _copyToClipboard,
                  child: Text('复制到剪贴板'),
                ),
              ),
            ],

            const Divider(height: 30),

            Text('导入数据'),
            const SizedBox(height: 8),
            Text(
              '粘贴导出的字符串到下方输入框进行数据导入',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '在此粘贴导出的字符串...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _importData = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton.icon(
                onPressed: _importData.isNotEmpty && !_isImporting
                    ? _importDataFunc
                    : null,
                icon: _isImporting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.download, size: 16),
                label: Text(_isImporting ? '导入中...' : '导入数据'),
              ),
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _message,
                style: TextStyle(
                  fontSize: 12,
                  color: _message.contains('成功')
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('关闭')),
      ],
    );
  }

  Future<void> _exportDataFunc() async {
    setState(() {
      _isExporting = true;
      _exportData = '';
      _message = '';
    });

    try {
      final dataString = await DataExportService.instance.exportDataToString();
      setState(() {
        _exportData = dataString;
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('数据导出成功!')));
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
        _message = '导出失败: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_message)));
      }
    }
  }

  Future<void> _importDataFunc() async {
    setState(() {
      _isImporting = true;
      _message = '';
    });

    try {
      await DataExportService.instance.importDataFromString(_importData);
      setState(() {
        _isImporting = false;
        _message = '数据导入成功!';
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('数据导入成功! 重启即可刷新')));
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _message = '导入失败: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_message)));
      }
    }
  }

  void _copyToClipboard() {
    FlutterClipboard.copy(_exportData).then((value) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
      }
    });
  }
}
