import 'package:flutter/material.dart';
import 'package:jiyi/data/notifier.dart';

class BtmAppbarWidget extends StatelessWidget {
  const BtmAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return BottomAppBar(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  isDarkMode.value = !isDarkMode.value;
                },
                icon: Icon(value ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
        );
      },
    );
  }
}
