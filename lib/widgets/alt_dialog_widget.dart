import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiyi/models/transcation.dart';

class AltDialogWidget extends StatefulWidget {
  final String title;
  final Transaction? transaction;

  const AltDialogWidget({super.key, required this.title, this.transaction});

  @override
  State<AltDialogWidget> createState() => _AltDialogWidgetState();
}

class _AltDialogWidgetState extends State<AltDialogWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _nameController.text = widget.transaction!.name;
      _dateController.text = widget.transaction!.date;
      _moneyController.text = widget.transaction!.money.toString();
    } else {
      _nameController.text = '';
      _moneyController.text = '';
      DateTime now = DateTime.now();
      String date = DateFormat('yyyy-M-d H:m').format(now);
      _dateController.text = date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  TransactionType _transactionType = TransactionType.expense;
  bool iconColor = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: Column(
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text('类型'),
              SegmentedButton<TransactionType>(
                selectedIcon: Icon(
                  Icons.check_circle,
                  color: iconColor
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
                ),
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    icon: Icon(Icons.money),
                    label: Text('支出'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    icon: Icon(Icons.wallet),
                    label: Text('收入'),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                    iconColor = !iconColor;
                  });
                },
              ),
            ],
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '名称',
              hintText: _nameController.text,
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _moneyController,
            decoration: InputDecoration(
              labelText: '金额',
              hintText: _moneyController.text,
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              //icon: Icon(Icons.calendar_month_outlined),
              label: Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.outline,
              ),
              //labelText: '日期',
              hintText: _moneyController.text,
              border: OutlineInputBorder(),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
      actions: [
        FilledButton(onPressed: () {}, child: Text('保存')),
        TextButton(onPressed: () {}, child: Text('取消')),
      ],
    );
  }
}
