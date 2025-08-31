import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _nameController.text = widget.transaction!.name;
      _moneyController.text = widget.transaction!.money.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        children: [
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
        ],
      ),
      actions: [
        FilledButton(onPressed: () {}, child: Text('保存')),
        TextButton(onPressed: () {}, child: Text('取消')),
      ],
    );
  }
}
