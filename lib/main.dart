import 'package:flutter/material.dart';
import 'package:jiyi/views/widget_tree.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MaterialColor _primaryColor = Colors.orange;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt('theme_color') ?? 0xFFFFA500;

      setState(() {
        _primaryColor = _getColorFromValue(colorValue);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _primaryColor = Colors.orange;
        _isLoading = false;
      });
    }
  }

  MaterialColor _getColorFromValue(int value) {
    final List<Map<String, dynamic>> colorMap = [
      {'color': Colors.orange, 'value': 0xFFFFA500},
      {'color': Colors.blue, 'value': 0xFF2196F3},
      {'color': Colors.green, 'value': 0xFF4CAF50},
      {'color': Colors.purple, 'value': 0xFF9C27B0},
      {'color': Colors.red, 'value': 0xFFF44336},
      {'color': Colors.teal, 'value': 0xFF009688},
    ];

    for (var colorEntry in colorMap) {
      if (colorEntry['value'] == value) {
        return colorEntry['color'];
      }
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      title: '记易',
      home: WidgetTree(),
    );
  }
}
