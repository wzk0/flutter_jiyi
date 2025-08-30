import 'package:flutter/material.dart';

class ExpdCardWidget extends StatelessWidget {
  final Widget child;
  final Color bgcolor;

  const ExpdCardWidget({super.key, required this.child, required this.bgcolor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bgcolor,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
