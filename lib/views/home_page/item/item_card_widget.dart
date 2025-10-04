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
    // weekday 是 1~7，对应 List 的索引 0~6
    return weekdays[date.weekday - 1];
  }

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
    return '${date.year}年${date.month.toString()}月${date.day.toString()}日 ${date.hour.toString()}点${date.minute.toString()}分 ${_getChineseWeekday(date)}';
  }

  String getFirstCharacterBeforeDash(String name) {
    // 如果没有 '-'，按你的逻辑返回 '-' 或原字符串？你原逻辑是返回 '-'
    if (!name.contains('-')) {
      return '-'; // 或 return name.characters.first.toString();
    }

    // 找到第一个 '-' 的位置（在原始字符串中）
    final dashIndex = name.indexOf('-');
    if (dashIndex <= 0) {
      return '-'; // 没有有效前缀
    }

    // 取 '-' 之前的部分
    final prefix = name.substring(0, dashIndex);

    // 使用 characters 安全取第一个“用户可见字符”
    final firstChar = prefix.characters.firstOrNull;
    return firstChar?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _getHabitPreference(), // 读取SharedPreferences中的habit值
      builder: (context, snapshot) {
        final bool isHabitEnabled = snapshot.data ?? false; // 默认为false

        return Card(
          margin: const EdgeInsets.all(5),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            // 根据habit设置交换手势
            onLongPress: isHabitEnabled ? onEdit : onDelete,
            onDoubleTap: isHabitEnabled ? onDelete : onEdit,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FutureBuilder<bool>(
                future: _getIsIconPreference(), // 读取SharedPreferences中的is_icon值
                builder: (context, iconSnapshot) {
                  final bool isIconEnabled =
                      iconSnapshot.data ?? false; // 默认为false

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
                                    isCost ? Icons.money : Icons.wallet, // 使用图标
                                    color: isCost
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                  )
                                : Text(
                                    getFirstCharacterBeforeDash(name), // 使用文本
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
                      Container(
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 6,
                          bottom: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isCost
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        child: Text(
                          isCost ? '¥ -$money' : '¥ $money',
                          style: TextStyle(
                            color: isCost
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  // 读取SharedPreferences中的is_icon值
  Future<bool> _getIsIconPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_icon') ?? false; // 默认为false
  }

  // 读取SharedPreferences中的habit值
  Future<bool> _getHabitPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('habit') ?? false; // 默认为false
  }
}
