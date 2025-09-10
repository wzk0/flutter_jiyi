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

  MaterialColor? _currentThemeColor; // 改为可空类型

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
    return Colors.orange; // 默认返回橙色
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // 主题颜色设置
          _buildThemeColorSection(),

          const Divider(),

          // 关于应用
          _buildAboutSection(),
        ],
      ),
    );
  }

  // 构建主题颜色设置部分
  Widget _buildThemeColorSection() {
    // 如果还没加载完成，显示加载指示器
    if (_currentThemeColor == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '主题颜色',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _themeColors.map((colorEntry) {
              return _buildColorOption(
                colorEntry['color'],
                colorEntry['value'],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 构建颜色选项
  Widget _buildColorOption(MaterialColor color, int colorValue) {
    // 确保_currentThemeColor不为null
    final bool isSelected =
        _currentThemeColor != null && color == _currentThemeColor;

    return GestureDetector(
      onTap: () => _changeThemeColor(color, colorValue),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: color, blurRadius: 8)]
              : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
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
          content: Text('主题颜色已更改为${_getColorName(newColor)}, 请重启动以应用新主题.'),
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

  // 构建关于应用部分
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '关于应用',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('关于记易'),
          onTap: _showAboutDialog,
        ),
      ],
    );
  }

  // 显示关于对话框
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '记易',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.money, size: 48),
      applicationLegalese: '© 2025 记易团队',
      children: [
        const SizedBox(height: 16),
        const Text('一个简洁实用的记账应用'),
        const SizedBox(height: 8),
        const Text('帮助您更好地管理个人财务'),
      ],
    );
  }
}
