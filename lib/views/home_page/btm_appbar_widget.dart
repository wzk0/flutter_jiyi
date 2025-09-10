import 'package:flutter/material.dart';
import 'package:jiyi/views/analytics_page/analytics_page.dart';
import 'package:jiyi/views/settings_page/settings_page.dart';

class BtmAppbarWidget extends StatelessWidget {
  const BtmAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AnalyticsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }
}
