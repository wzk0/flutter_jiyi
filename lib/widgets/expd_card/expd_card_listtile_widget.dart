import 'package:flutter/material.dart';

class ExpdCardListtileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leading;

  const ExpdCardListtileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(icon: Icon(Icons.list_alt), onPressed: () {}),
      leading: Text(leading, style: TextStyle(fontSize: 13)),
    );
  }
}
