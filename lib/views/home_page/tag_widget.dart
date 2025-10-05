import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String tag;
  final Color bgcolor;
  final Color txcolor;

  const TagWidget({
    super.key,
    required this.tag,
    required this.bgcolor,
    required this.txcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(tag, style: TextStyle(color: txcolor, fontSize: 10)),
    );
  }
}
