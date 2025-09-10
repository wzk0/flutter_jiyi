import 'package:flutter/material.dart';

class DrawerTitleWidget extends StatelessWidget {
  final String actions;

  const DrawerTitleWidget({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        actions,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
