import 'package:flutter/material.dart';
import 'package:jiyi/models/transcation.dart';
import 'package:jiyi/widgets/alt_dialog_widget.dart';

class Fab extends StatelessWidget {
  const Fab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AltDialogWidget(title: '记一笔账', transaction: Transaction(name: '123', money: 100),);
          },
        );
      },
      icon: Icon(Icons.add),
      label: Text('记一笔'),
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
    );
  }
}
