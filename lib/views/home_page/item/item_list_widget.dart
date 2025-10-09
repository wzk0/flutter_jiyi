import 'package:flutter/material.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/views/home_page/item/item_card_widget.dart';

class ItemListWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction)? onEdit;
  final Function(Transaction)? onDelete;
  final bool showYearDivider;
  final bool showMonthDivider;
  final bool showDayDivider;
  final double topMoney;

  const ItemListWidget({
    super.key,
    required this.transactions,
    this.onEdit,
    this.onDelete,
    this.showYearDivider = false,
    this.showMonthDivider = false,
    this.showDayDivider = false,
    this.topMoney = 0,
  });

  String _getChineseWeekday(DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          '暂无账目数据',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      );
    }

    if (!showYearDivider && !showMonthDivider && !showDayDivider) {
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

    final itemsWithDividers = _buildItemsWithDividers(context);

    return ListView.builder(
      itemCount: itemsWithDividers.length,
      itemBuilder: (context, index) {
        final item = itemsWithDividers[index];
        if (item is Widget) {
          return item;
        } else if (item is Transaction) {
          return ItemCardWidget(
            transaction: item,
            onEdit: onEdit != null ? () => onEdit!(item) : null,
            onDelete: onDelete != null ? () => onDelete!(item) : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<Object> _buildItemsWithDividers(BuildContext context) {
    final List<Object> items = [];

    if (transactions.isEmpty) return items;

    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    String? lastYear;
    String? lastMonth;
    String? lastDay;

    final yearStats = <String, Map<String, double>>{};
    final monthStats = <String, Map<String, double>>{};
    final dayStats = <String, Map<String, double>>{};

    for (final transaction in sortedTransactions) {
      final yearKey = '${transaction.date.year}年';
      final monthKey = '${transaction.date.year}年${transaction.date.month}月';
      final dayKey =
          '${transaction.date.year}年${transaction.date.month}月${transaction.date.day}日';

      yearStats.putIfAbsent(yearKey, () => {'income': 0, 'expense': 0});
      if (transaction.type == TransactionType.income) {
        yearStats[yearKey]!['income'] =
            yearStats[yearKey]!['income']! + transaction.money;
      } else {
        yearStats[yearKey]!['expense'] =
            yearStats[yearKey]!['expense']! + transaction.money;
      }

      monthStats.putIfAbsent(monthKey, () => {'income': 0, 'expense': 0});
      if (transaction.type == TransactionType.income) {
        monthStats[monthKey]!['income'] =
            monthStats[monthKey]!['income']! + transaction.money;
      } else {
        monthStats[monthKey]!['expense'] =
            monthStats[monthKey]!['expense']! + transaction.money;
      }

      dayStats.putIfAbsent(dayKey, () => {'income': 0, 'expense': 0});
      if (transaction.type == TransactionType.income) {
        dayStats[dayKey]!['income'] =
            dayStats[dayKey]!['income']! + transaction.money;
      } else {
        dayStats[dayKey]!['expense'] =
            dayStats[dayKey]!['expense']! + transaction.money;
      }
    }

    for (int i = 0; i < sortedTransactions.length; i++) {
      final transaction = sortedTransactions[i];
      final transactionYear = '${transaction.date.year}年';
      final transactionMonth =
          '${transaction.date.year}年${transaction.date.month}月';
      final transactionDay =
          '${transaction.date.year}年${transaction.date.month}月${transaction.date.day}日';

      if (showYearDivider &&
          (lastYear == null || lastYear != transactionYear)) {
        items.add(
          _buildYearDivider(
            context,
            transaction.date,
            yearStats[transactionYear]!,
          ),
        );
        lastYear = transactionYear;
      }

      if (showMonthDivider &&
          (lastMonth == null || lastMonth != transactionMonth)) {
        items.add(
          _buildMonthDivider(
            context,
            transaction.date,
            monthStats[transactionMonth]!,
          ),
        );
        lastMonth = transactionMonth;
      }

      if (showDayDivider && (lastDay == null || lastDay != transactionDay)) {
        items.add(
          _buildDayDivider(
            context,
            transaction.date,
            dayStats[transactionDay]!,
          ),
        );
        lastDay = transactionDay;
      }

      items.add(transaction);
    }

    return items;
  }

  Widget _buildYearDivider(
    BuildContext context,
    DateTime date,
    Map<String, double> stats,
  ) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 5,
        children: [
          Text(
            '${date.year}年',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          const Expanded(child: Divider()),
          Text(
            '收入: ¥ ${stats['income']!.toStringAsFixed(2)} 支出: ¥ ${stats['expense']!.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDivider(
    BuildContext context,
    DateTime date,
    Map<String, double> stats,
  ) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 5,
        children: [
          Text(
            '${date.year}年${date.month}月',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          const Expanded(child: Divider()),
          Text(
            '收入: ¥ ${stats['income']!.toStringAsFixed(2)} 支出: ¥ ${stats['expense']!.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDivider(
    BuildContext context,
    DateTime date,
    Map<String, double> stats,
  ) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 5,
        children: [
          Text(
            '${date.year}年${date.month}月${date.day}日 ${_getChineseWeekday(date)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          const Expanded(child: Divider()),
          Text(
            (topMoney == 0)
                ? '合计: ¥ ${(stats['income']! - stats['expense']!).toStringAsFixed(2)} (+${stats['income']!.toStringAsFixed(2)}│-${stats['expense']!.toStringAsFixed(2)})'
                : '剩余: ¥ ${(topMoney - stats['expense']! + stats['income']!).toStringAsFixed(2)} (+${stats['income']!.toStringAsFixed(2)}│-${stats['expense']!.toStringAsFixed(2)})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
