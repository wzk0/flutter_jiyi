import 'package:flutter/material.dart';
import 'package:jiyi/views/home_page/alt_dialog_widget.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';

class Fab extends StatelessWidget {
  final VoidCallback? onTransactionAdded;

  const Fab({super.key, this.onTransactionAdded});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context),
      icon: Icon(Icons.add),
      label: Text('记一笔'),
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
    );
  }

  void _showAddDialog(BuildContext context) async {
    final result = await showDialog<Transaction>(
      context: context,
      builder: (context) => AltDialogWidget(title: '记一笔账', transaction: null),
    );

    if (result != null) {
      try {
        // 保存到数据库
        await DatabaseService.instance.insertTransaction(result);

        // 通知父组件数据已更新
        if (onTransactionAdded != null) {
          onTransactionAdded!();
        }

        // 显示成功提示
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('添加成功')));
        }
      } catch (e) {
        // 显示错误提示
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
        }
      }
    }
  }
}
