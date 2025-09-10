import 'package:flutter/material.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/widgets/item/item_card_widget.dart';

class ItemListWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction)? onEdit; // 添加编辑回调
  final Function(Transaction)? onDelete; // 添加删除回调

  const ItemListWidget({
    super.key,
    required this.transactions,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          '暂无交易记录',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return ItemCardWidget(
          transaction: transactions[index],
          onEdit: onEdit != null ? () => onEdit!(transactions[index]) : null,
          onDelete: onDelete != null
              ? () => onDelete!(transactions[index])
              : null,
        );
      },
    );
  }
}
