import 'package:flutter/material.dart';
import 'package:jiyi/widgets/item/item_card_widget.dart';

class ItemListWidget extends StatefulWidget {
  const ItemListWidget({super.key});

  @override
  State<ItemListWidget> createState() => _AtcListState();
}

class _AtcListState extends State<ItemListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ItemCardWidget(
          title: '冰红茶',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: true,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
        ItemCardWidget(
          title: '红包',
          date: '2025-08-28 18:54',
          icon: Icons.money,
          isCost: false,
          money: 100.00,
        ),
      ],
    );
  }
}
