import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 主题颜色选项
  final List<Map<String, dynamic>> _themeColors = [
    {'color': Colors.orange, 'value': 0xFFFFA500, 'name': '橙色'},
    {'color': Colors.blue, 'value': 0xFF2196F3, 'name': '蓝色'},
    {'color': Colors.green, 'value': 0xFF4CAF50, 'name': '绿色'},
    {'color': Colors.purple, 'value': 0xFF9C27B0, 'name': '紫色'},
    {'color': Colors.red, 'value': 0xFFF44336, 'name': '红色'},
    {'color': Colors.teal, 'value': 0xFF009688, 'name': '蓝绿色'},
  ];

  MaterialColor? _currentThemeColor;

  @override
  void initState() {
    super.initState();
    _loadThemeColor();
  }

  // 加载保存的主题颜色
  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('theme_color') ?? 0xFFFFA500;

    setState(() {
      // 根据保存的颜色值找到对应的MaterialColor
      _currentThemeColor = _getColorFromValue(colorValue);
    });
  }

  // 保存主题颜色
  Future<void> _saveThemeColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', colorValue);
  }

  // 根据颜色值获取MaterialColor
  MaterialColor _getColorFromValue(int value) {
    for (var colorEntry in _themeColors) {
      if (colorEntry['value'] == value) {
        return colorEntry['color'];
      }
    }
    return Colors.orange;
  }

  // 获取颜色值

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: ExpansionTile(
                  title: Text('主题色'),
                  leading: Icon(Icons.color_lens),
                  children: _buildColorOptions(),
                ),
              ),
            ),
            Divider(height: 40),
          ],
        ),
      ),
    );
  }

  // 构建颜色选项列表
  List<Widget> _buildColorOptions() {
    if (_currentThemeColor == null) {
      return [
        const ListTile(
          title: Text('加载中...'),
          leading: CircularProgressIndicator(),
          dense: true,
        ),
      ];
    }

    return _themeColors.map((colorEntry) {
      final color = colorEntry['color'];
      final name = colorEntry['name'];
      final value = colorEntry['value'];
      final isSelected =
          _currentThemeColor != null && color == _currentThemeColor;

      return ListTile(
        title: Text(name),
        trailing: isSelected ? Icon(Icons.check) : null,
        leading: Icon(Icons.circle, color: color),
        onTap: () => _changeThemeColor(color, value),
        dense: true,
      );
    }).toList();
  }

  // 更改主题颜色
  void _changeThemeColor(MaterialColor newColor, int colorValue) {
    setState(() {
      _currentThemeColor = newColor;
    });

    // 保存到本地
    _saveThemeColor(colorValue);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('主题颜色已更改为${_getColorName(newColor)}, 重启以应用'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // 获取颜色名称
  String _getColorName(MaterialColor color) {
    for (var colorEntry in _themeColors) {
      if (colorEntry['color'] == color) {
        return colorEntry['name'];
      }
    }
    return '主题色';
  }
}
