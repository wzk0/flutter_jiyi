import 'package:flutter/material.dart';

class BtmAppbarWidget extends StatelessWidget {
  const BtmAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
          IconButton(onPressed: () {}, icon: Icon(Icons.download)),
        ],
      ),
    );
  }
}
