import 'package:flutter/material.dart';

class AltDialogWidget extends StatelessWidget {
  final String title;

  const AltDialogWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [TextField(), TextField(), TextField(), TextField()],
      ),
      actions: [
        FilledButton(onPressed: () {}, child: Text('保存')),
        TextButton(onPressed: () {}, child: Text('取消')),
      ],
    );
  }
}
