import 'package:flutter/material.dart';

class ExpdCardHighestWidget extends StatelessWidget {
  final double money;
  final String descr;
  final Color bgcolor;
  final Color txcolor;

  const ExpdCardHighestWidget({
    super.key,
    required this.money,
    required this.descr,
    required this.bgcolor, required this.txcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: bgcolor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 5,
            children: [
              Text('¥ $money', style: TextStyle(fontSize: 26, color: txcolor)),
              Text(
                descr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
