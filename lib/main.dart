import 'package:flutter/material.dart';
import 'package:jiyi/data/notifier.dart';
import 'package:jiyi/views/widget_tree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return MaterialApp(
          theme: ThemeData(
            colorSchemeSeed: Colors.orange,
            brightness: value ? Brightness.dark : Brightness.light,
            useMaterial3: true,
          ),
          title: '记易',
          home: WidgetTree(),
        );
      },
    );
  }
}
