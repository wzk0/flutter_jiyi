import 'package:flutter/material.dart';
import 'package:jiyi/widgets/tag_widget.dart';

class ItemCardWidget extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final bool isCost;
  final double money;

  const ItemCardWidget({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    required this.isCost,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
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
                  child: Icon(icon),
                ),
                SizedBox(height: 38, child: VerticalDivider(width: 32)),
                Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Text(
                          title,
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
                          date,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    //TagWidget(tag: date, bgcolor: Colors.transparent, txcolor: Theme.of(context).colorScheme.outline),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isCost
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                IconButton(
                  onPressed: () {},
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
