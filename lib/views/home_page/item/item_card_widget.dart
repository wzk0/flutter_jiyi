import 'package:flutter/material.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/views/home_page/tag_widget.dart';

class ItemCardWidget extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCardWidget({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  // 从transaction中提取属性
  String get name => transaction.name;
  double get money => transaction.money;
  DateTime get date => transaction.date;
  bool get isCost => transaction.type == TransactionType.expense;

  // 为图标添加默认值
  IconData get icon {
    if (isCost) {
      return Icons.money;
    } else {
      return Icons.wallet;
    }
  }

  String get formattedDate {
    final date = transaction.date;
    return '${date.year}年${date.month.toString()}月${date.day.toString()}日 ${date.hour.toString()}点${date.minute.toString()}分';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCost
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.tertiaryContainer,
                  child: Icon(
                    icon,
                    color: isCost
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 38, child: VerticalDivider(width: 32)),
                Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCost
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        TagWidget(
                          tag: isCost ? 'OUT' : 'IN',
                          bgcolor: isCost
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.tertiaryContainer,
                          txcolor: isCost
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                        TagWidget(
                          tag: '¥ $money',
                          bgcolor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          txcolor: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 3,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).colorScheme.outline,
                          size: 13,
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isCost
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: isCost
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
