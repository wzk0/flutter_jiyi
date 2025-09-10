import 'package:flutter/material.dart';

class ExpdCardListtileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leading;
  final bool bgcolor;

  const ExpdCardListtileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.bgcolor,
  });

  @override
  Widget build(BuildContext context) {
    // 根据 bgcolor 决定图标
    final icon = bgcolor ? Icons.money : Icons.wallet;

    // 根据 leading 决定颜色
    final isIncome = leading == '收入';
    final color = isIncome
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(icon, color: color),
        SizedBox(height: 30, child: VerticalDivider()),
        Text(title, style: TextStyle(fontSize: 16, color: color)),
        Text(subtitle, style: TextStyle(color: color)),
      ],
    );
  }
}
