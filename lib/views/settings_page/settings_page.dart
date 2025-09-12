import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // 分割线设置
  bool _showYearDivider = false;
  bool _showMonthDivider = false;
  bool _showDayDivider = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 加载所有设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载主题颜色
    final colorValue = prefs.getInt('theme_color') ?? 0xFFFFA500;
    setState(() {
      _currentThemeColor = _getColorFromValue(colorValue);
    });

    // 加载分割线设置
    setState(() {
      _showYearDivider = prefs.getBool('show_year_divider') ?? false;
      _showMonthDivider = prefs.getBool('show_month_divider') ?? false;
      _showDayDivider = prefs.getBool('show_day_divider') ?? false;
    });
  }

  // 保存主题颜色
  Future<void> _saveThemeColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', colorValue);
  }

  // 保存分割线设置
  Future<void> _saveDividerSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      // 强制使用外部应用（系统浏览器）打开
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
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
                    leading: Icon(Icons.color_lens_outlined),
                    children: _buildColorOptions(),
                  ),
                ),
              ),
              Divider(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('年分割线'),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: _showYearDivider,
                      onChanged: (value) {
                        setState(() {
                          _showYearDivider = value;
                        });
                        _saveDividerSetting('show_year_divider', value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('月分割线'),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: _showMonthDivider,
                      onChanged: (value) {
                        setState(() {
                          _showMonthDivider = value;
                        });
                        _saveDividerSetting('show_month_divider', value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('日分割线'),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: _showDayDivider,
                      onChanged: (value) {
                        setState(() {
                          _showDayDivider = value;
                        });
                        _saveDividerSetting('show_day_divider', value);
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 40),
              ListTile(
                leading: Icon(Icons.tips_and_updates_outlined),
                title: Text('提示'),
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('关于'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: '记易',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 thdbd',
                    applicationIcon: Icon(
                      Icons.money,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: Text('源代码'),
                onTap: () {
                  _launchInBrowser('https://github.com/wzk0/flutter_jiyi  ');
                },
              ),
            ],
          ),
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
