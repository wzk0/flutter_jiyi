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

  // 设置选项
  bool _showYearDivider = false;
  bool _showMonthDivider = false;
  bool _showDayDivider = false;
  bool _isIconEnabled = false; // 图标开关

  bool _settingsLoaded = false; // 标记设置是否已加载

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

    // 加载分割线设置
    final showYearDivider = prefs.getBool('show_year_divider') ?? false;
    final showMonthDivider = prefs.getBool('show_month_divider') ?? false;
    final showDayDivider = prefs.getBool('show_day_divider') ?? false;
    final isIconEnabled = prefs.getBool('is_icon') ?? false; // 加载图标设置

    setState(() {
      _currentThemeColor = _getColorFromValue(colorValue);
      _showYearDivider = showYearDivider;
      _showMonthDivider = showMonthDivider;
      _showDayDivider = showDayDivider;
      _isIconEnabled = isIconEnabled;
      _settingsLoaded = true; // 标记设置已加载完成
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

  // 保存图标设置
  Future<void> _saveIconSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_icon', value);
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '主题色',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '分割线',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('年分割线'),
                      subtitle: Text(
                        '在首页显示以年为单位的分割线, 如"2025年"',
                        style: TextStyle(fontSize: 12),
                      ),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: _settingsLoaded
                          ? _showYearDivider
                          : false, // 使用加载状态
                      onChanged: (value) {
                        setState(() {
                          _showYearDivider = value;
                        });
                        _saveDividerSetting('show_year_divider', value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('月分割线'),
                      subtitle: Text(
                        '在首页显示以年月为单位的分割线, 如"2025年9月"',
                        style: TextStyle(fontSize: 12),
                      ),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: _settingsLoaded
                          ? _showMonthDivider
                          : false, // 使用加载状态
                      onChanged: (value) {
                        setState(() {
                          _showMonthDivider = value;
                        });
                        _saveDividerSetting('show_month_divider', value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('日分割线'),
                      subtitle: Text(
                        '在首页显示以年月日为单位的分割线, 如"2025年9月1日 星期一"',
                        style: TextStyle(fontSize: 12),
                      ),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: _settingsLoaded
                          ? _showDayDivider
                          : false, // 使用加载状态
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'LOGO',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: SwitchListTile(
                  value: _settingsLoaded ? _isIconEnabled : false, // 使用加载状态
                  onChanged: (value) {
                    setState(() {
                      _isIconEnabled = value;
                    });
                    _saveIconSetting(value); // 保存图标设置
                  },
                  title: Text('卡片图标LOGO'),
                  subtitle: Text(
                    '在首页账目卡片启用固定图标LOGO, 否则显示分类的第一个字. 如"饮料-冰红茶"则会显示"饮"',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(height: 40),
              ListTile(
                leading: Icon(Icons.tips_and_updates_outlined),
                title: Text('提示'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text('提示'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '感谢🙏使用记易! 这是一款个人开发的记账软件, 使用Flutter进行构建, 过程中如果发现bug, 如果可以的话请帮忙提个issue!',
                            ),
                            Divider(),
                            Text(
                              '在首页, 您可以通过点击右下角"记一笔"按钮进行记账. 记账要求您必须输入金额, 名称如果留白则会被命名为"未命名账目".',
                            ),
                            Text(
                              '保存完成后, 该笔账目便会出现在首页. 如果您想要日期分割线, 可以在左下角设置按钮中进行设置. 同时, 您还可以在设置页面中进行主题色的设置, 以及发现本篇"提示".',
                            ),
                            Text(
                              '每条账目的后面都有编辑按钮与删除按钮, 点击即可进行对应操作. ⚠️注意: 删除的账目无法进行找回!',
                            ),
                            Divider(),
                            Text(
                              '点击首页左上角即可打开侧边栏速览账目数据总结. 包括最上方的今日总收入与总支出(后方有一个饼图显示占比), 所有时间段的总收入与总支出, 以及至今为止最高的一笔收入与支出.',
                            ),
                            Divider(),
                            Text(
                              '您可以发现: 收入组件永远在支出的上方/左侧. 同时, 收入相关组件的配色会使用Material Design的Tertiary色系, 而支出相关组件的配色则会使用Primary色系.',
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 15,
                                ),
                                Text('这是收入相关组件的主题色.'),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 15,
                                ),
                                Text('而这是支出相关组件的主题色.'),
                              ],
                            ),
                            Divider(),
                            Text('收入与支出的图标也不同.'),
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.wallet,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 15,
                                ),
                                Text('这是收入相关组件的图标.'),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.money,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 15,
                                ),
                                Text('而这是支出相关组件的图标.'),
                              ],
                            ),
                            Divider(),
                            Text('记易具有账目分析功能. 只需要点击左下角分析按钮(设置按钮右方)即可进行查看.'),
                            Text(
                              '包括周度, 月度以及年度分析. 涵盖"该时间段内最高收入与支出", "收支对比", "收入与支出趋势", "收入与支出分类", "结余率计算"等.',
                            ),
                            Divider(),
                            Text(
                              '因此, 在使用记易进行记账时, 如果您使用相同的账目名称, 例如: "早餐", "购物", "旅行"(后续会支持模糊分类统计), 可以更好地查看数据分析.',
                            ),
                            Divider(),
                            Text('目前就是这样. 再次感谢🙏使用记易!'),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('关于'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: '记易',
                    applicationVersion: '0.0.1',
                    applicationLegalese: '© 2025 wzk0 & thdbd',
                    applicationIcon: Image.asset(
                      'assets/icon/1024.png',
                      width: 55,
                      height: 55,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: Text('源代码'),
                onTap: () {
                  _launchInBrowser('https://github.com/wzk0/flutter_jiyi    ');
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
