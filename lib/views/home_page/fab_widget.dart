import 'package:flutter/material.dart';
import 'package:jiyi/views/home_page/alt_dialogs/alt_dialog_widget.dart';
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
        await DatabaseService.instance.insertTransaction(result);

        if (onTransactionAdded != null) {
          onTransactionAdded!();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('添加成功')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
        }
      }
    }
  }
}
