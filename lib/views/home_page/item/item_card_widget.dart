import 'package:flutter/material.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/views/home_page/tag_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _getChineseWeekday(DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }

  String get name => transaction.name;
  double get money => transaction.money;
  DateTime get date => transaction.date;
  bool get isCost => transaction.type == TransactionType.expense;

  IconData get icon {
    if (isCost) {
      return Icons.money;
    } else {
      return Icons.wallet;
    }
  }

  String get formattedDate {
    final date = transaction.date;
    return '${date.year}年${date.month.toString()}月${date.day.toString()}日 ${date.hour.toString()}点${date.minute.toString()}分 ${_getChineseWeekday(date)}';
  }

  String getFirstCharacterBeforeDash(String name) {
    if (!name.contains('-')) {
      return '-';
    }
    final dashIndex = name.indexOf('-');
    if (dashIndex <= 0) {
      return '-';
    }
    final prefix = name.substring(0, dashIndex);
    final firstChar = prefix.characters.firstOrNull;
    return firstChar?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: _getHabitPreference(),
      builder: (context, snapshot) {
        final bool isHabitEnabled = snapshot.data?[0] ?? false;
        final bool isMoneyPosition = snapshot.data?[1] ?? false;

        return Card(
          margin: const EdgeInsets.all(5),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onLongPress: isHabitEnabled ? onEdit : onDelete,
            onDoubleTap: isHabitEnabled ? onDelete : onEdit,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FutureBuilder<bool>(
                future: _getIsIconPreference(),
                builder: (context, iconSnapshot) {
                  final bool isIconEnabled = iconSnapshot.data ?? false;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isCost
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer,
                            child: isIconEnabled
                                ? Icon(
                                    isCost ? Icons.money : Icons.wallet,
                                    color: isCost
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                  )
                                : Text(
                                    getFirstCharacterBeforeDash(name),
                                    style: TextStyle(
                                      color: isCost
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                    ),
                                  ),
                          ),
                          const SizedBox(
                            height: 38,
                            child: VerticalDivider(width: 32),
                          ),
                          Column(
                            spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 5,
                                children: name.contains('-')
                                    ? [
                                        Text(
                                          (name.split('-').last).length > 10
                                              ? '${(name.split('-').last).substring(0, 9)}...'
                                              : name.split('-').last,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isCost
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                          ),
                                        ),
                                        TagWidget(
                                          tag: isCost ? '支出' : '收入',
                                          bgcolor: isCost
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryContainer,
                                          txcolor: isCost
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                        ),
                                        TagWidget(
                                          tag: name.split('-').first,
                                          bgcolor: isCost
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryContainer,
                                          txcolor: isCost
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                        ),
                                        isMoneyPosition
                                            ? SizedBox()
                                            : TagWidget(
                                                tag: '¥ $money',
                                                bgcolor: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer,
                                                txcolor: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                              ),
                                      ]
                                    : [
                                        Text(
                                          (name.split('-').last).length > 10
                                              ? '${(name.split('-').last).substring(0, 9)}...'
                                              : name.split('-').last,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isCost
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                          ),
                                        ),
                                        TagWidget(
                                          tag: isCost ? '支出' : '收入',
                                          bgcolor: isCost
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryContainer,
                                          txcolor: isCost
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                        ),
                                        name.contains('-')
                                            ? TagWidget(
                                                tag: name[0],
                                                bgcolor: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer,
                                                txcolor: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                              )
                                            : SizedBox(),
                                        isMoneyPosition
                                            ? SizedBox()
                                            : TagWidget(
                                                tag: '¥ $money',
                                                bgcolor: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer,
                                                txcolor: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                              ),
                                      ],
                              ),
                              Row(
                                spacing: 3,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    size: 13,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      isMoneyPosition
                          ? Container(
                              padding: EdgeInsets.only(
                                left: 7,
                                right: 7,
                                top: 5,
                                bottom: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isCost
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.tertiaryContainer,
                              ),
                              child: Text(
                                isCost ? '¥ -$money' : '¥ $money',
                                style: TextStyle(
                                  color: isCost
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.tertiary,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _getIsIconPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_icon') ?? false;
  }

  Future<List> _getHabitPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool habit = prefs.getBool('habit') ?? false;
    bool moneyposition = prefs.getBool('moneyposition') ?? false;
    return [habit, moneyposition];
  }
}
