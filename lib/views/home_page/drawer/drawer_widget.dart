import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/services/update_service.dart';
import 'package:jiyi/views/ai_page/ai_page.dart';
import 'package:jiyi/views/home_page/drawer/drawer_title_widget.dart';
import 'package:jiyi/views/home_page/drawer/expd_card/expd_card_highest_widget.dart';
import 'package:jiyi/views/home_page/drawer/expd_card/expd_card_listtile_widget.dart';
import 'package:jiyi/views/home_page/drawer/expd_card/expd_card_widget.dart';
import 'package:jiyi/views/home_page/tag_widget.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:jiyi/views/home_page/import_export_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jiyi/services/ai_service.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  double _todayIncome = 0.0;
  double _todayExpense = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  int _incomeCount = 0;
  int _expenseCount = 0;
  Transaction? _highestIncome;
  Transaction? _highestExpense;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final transactions = await DatabaseService.instance.getTransactions();

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

      double todayIncome = 0.0;
      double todayExpense = 0.0;

      double totalIncome = 0.0;
      double totalExpense = 0.0;
      int incomeCount = 0;
      int expenseCount = 0;

      Transaction? highestIncomeTransaction;
      Transaction? highestExpenseTransaction;

      for (var transaction in transactions) {
        if (transaction.date.isAfter(todayStart) &&
            transaction.date.isBefore(todayEnd)) {
          if (transaction.type == TransactionType.income) {
            todayIncome += transaction.money;
          } else {
            todayExpense += transaction.money;
          }
        }

        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.money;
          incomeCount++;
          if (highestIncomeTransaction == null ||
              transaction.money > highestIncomeTransaction.money) {
            highestIncomeTransaction = transaction;
          }
        } else {
          totalExpense += transaction.money;
          expenseCount++;
          if (highestExpenseTransaction == null ||
              transaction.money > highestExpenseTransaction.money) {
            highestExpenseTransaction = transaction;
          }
        }
      }

      if (mounted) {
        setState(() {
          _todayIncome = todayIncome;
          _todayExpense = todayExpense;
          _totalIncome = totalIncome;
          _totalExpense = totalExpense;
          _incomeCount = incomeCount;
          _expenseCount = expenseCount;
          _highestIncome = highestIncomeTransaction;
          _highestExpense = highestExpenseTransaction;
        });
      }
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
    }
  }

  Future<void> _loadTransactions() async {
    await _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SafeArea(
            minimum: const EdgeInsets.all(10),
            child: Column(
              spacing: 7,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(),
                Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: Text(
                        '今日',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 40, child: VerticalDivider(width: 0)),
                    Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            TagWidget(
                              tag: '总收入',
                              bgcolor: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              txcolor: Theme.of(context).colorScheme.tertiary,
                            ),
                            Text(
                              '¥ ${_todayIncome.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            TagWidget(
                              tag: '总支出',
                              bgcolor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              txcolor: Theme.of(context).colorScheme.primary,
                            ),
                            Text(
                              '¥ ${_todayExpense.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: (_todayIncome + _todayExpense) > 0
                          ? PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: _todayExpense,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: _todayIncome,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiaryContainer,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            )
                          : Icon(
                              Icons.pie_chart,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                    ),
                  ],
                ),
                const Divider(),
                DrawerTitleWidget(actions: '统计'),
                Row(
                  children: [
                    ExpdCardWidget(
                      bgcolor: Theme.of(context).colorScheme.tertiaryContainer,
                      child: ExpdCardListtileWidget(
                        title: '¥ ${_totalIncome.toStringAsFixed(2)}',
                        subtitle: '共 $_incomeCount 笔',
                        leading: '收入',
                        bgcolor: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ExpdCardWidget(
                      bgcolor: Theme.of(context).colorScheme.primaryContainer,
                      child: ExpdCardListtileWidget(
                        title: '¥ ${_totalExpense.toStringAsFixed(2)}',
                        subtitle: '共 $_expenseCount 笔',
                        leading: '支出',
                        bgcolor: false,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                DrawerTitleWidget(actions: '至今'),
                Row(
                  spacing: 5,
                  children: [
                    ExpdCardHighestWidget(
                      money: _highestIncome?.money ?? 0,
                      descr: _highestIncome != null
                          ? '单笔最高收入\n(${_highestIncome!.name})'
                          : '暂无收入',
                      bgcolor: Theme.of(context).colorScheme.tertiaryContainer,
                      txcolor: Theme.of(context).colorScheme.tertiary,
                    ),
                    ExpdCardHighestWidget(
                      money: _highestExpense?.money ?? 0,
                      descr: _highestExpense != null
                          ? '单笔最高支出\n(${_highestExpense!.name})'
                          : '暂无支出',
                      bgcolor: Theme.of(context).colorScheme.primaryContainer,
                      txcolor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const Divider(),
                DrawerTitleWidget(actions: '操作'),
                Wrap(
                  spacing: 5,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _performAIAnalysis,
                      icon: Icon(Icons.lightbulb),
                      label: Text('智能分析'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _showImportExportDialog,
                      icon: Icon(Icons.swap_horiz),
                      label: Text('数据管理'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _checkForUpdates,
                      icon: Icon(Icons.system_update),
                      label: Text('检查更新'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performAIAnalysis() async {
    final hasKey = await AIAnalysisService.instance.hasApiKey();
    if (!hasKey) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('请先在设置中输入 Qwen API Key')));
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('分析中'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('正在分析您的账目数据...'),
            ],
          ),
        ),
      );
    }

    try {
      final analysisResult = await AIAnalysisService.instance
          .generateAnalysis();

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AiPage(result: analysisResult);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
      debugPrint('AI 分析失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AI 分析失败: $e')));
      }
    }
  }

  void _showImportExportDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ImportExportDialog(),
    );

    if (result == true) {
      await _loadTransactions();
    }
  }

  void _checkForUpdates() async {
    final snackBar = SnackBar(
      content: Text('正在检查更新...'),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      final updateInfo = await UpdateService.instance.checkForUpdates('0.0.34');

      if (updateInfo != null && updateInfo.isAvailable) {
        _showUpdateDialog(updateInfo);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('当前已是最新版本'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查更新失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: v${updateInfo.version}'),
            const SizedBox(height: 8),
            Text('更新内容:'),
            const SizedBox(height: 4),
            Text(updateInfo.releaseNotes, style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('稍后更新'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(updateInfo.downloadUrl);
            },
            child: Text('立即更新'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('无法打开链接');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打开链接失败: $e')));
      }
    }
  }
}
