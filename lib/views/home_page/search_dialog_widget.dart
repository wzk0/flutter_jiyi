import 'package:flutter/material.dart';

class SearchDialogWidget extends StatefulWidget {
  const SearchDialogWidget({super.key});

  @override
  State<SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<SearchDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text('搜索'));
  }
}
