import 'package:flutter/material.dart';
import 'package:jiyi/views/widget_tree.dart';
import 'package:jiyi/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 简单初始化，适用于移动端
  await DatabaseService.instance.database;

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
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.orange,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      title: '记易',
      home: WidgetTree(),
    );
  }
}
