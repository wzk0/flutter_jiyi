import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  AnalysisPeriod _currentPeriod = AnalysisPeriod.weekly;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await DatabaseService.instance.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载数据失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('数据分析'),
        actions: [
          IconButton(onPressed: _loadTransactions, icon: Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPeriodSelector(),
                Expanded(child: _buildAnalysisContent()),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<AnalysisPeriod>(
      segments: const [
        ButtonSegment(value: AnalysisPeriod.weekly, label: Text('周度')),
        ButtonSegment(value: AnalysisPeriod.monthly, label: Text('月度')),
        ButtonSegment(value: AnalysisPeriod.yearly, label: Text('年度')),
      ],
      selected: {_currentPeriod},
      onSelectionChanged: (Set<AnalysisPeriod> newSelection) {
        setState(() {
          _currentPeriod = newSelection.first;
        });
      },
    );
  }

  Widget _buildAnalysisContent() {
    final filteredTransactions = _filterTransactionsByPeriod(_currentPeriod);

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          '该时间段暂无数据',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      );
    }

    final stats = _calculateStatistics(filteredTransactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(stats),

          _buildHighestTransactionsCard(filteredTransactions),

          _buildIncomeExpenseChart(stats),

          _buildIncomeTrendChart(filteredTransactions),

          _buildExpenseTrendChart(filteredTransactions),

          _buildCategoryIncomeChart(filteredTransactions),

          _buildCategoryExpenseChart(filteredTransactions),

          _buildDetailedStats(stats),
        ],
      ),
    );
  }

  String _getCategoryName(String name) {
    if (name.contains('-')) {
      return name.split('-')[0];
    }
    return name;
  }

  Widget _buildCategoryIncomeChart(List<Transaction> transactions) {
    final categoryData = _calculateCategoryIncome(transactions);

    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('收入分类', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData
                      .map(
                        (data) => PieChartSectionData(
                          value: data.amount,
                          title:
                              '${data.category}\n${data.percentage.toStringAsFixed(1)}%',
                          titleStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          color: data.color,
                          showTitle: true,
                        ),
                      )
                      .toList(),
                  centerSpaceRadius: 60,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categoryData
                  .map(
                    (data) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.category}: ¥ ${data.amount.toStringAsFixed(2)} (${data.percentage.toStringAsFixed(1)}%)',
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryIncomeData> _calculateCategoryIncome(
    List<Transaction> transactions,
  ) {
    final incomeMap = <String, double>{};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        final category = _getCategoryName(transaction.name);
        incomeMap[category] = (incomeMap[category] ?? 0) + transaction.money;
      }
    }

    if (incomeMap.isEmpty) {
      return [];
    }

    final totalIncome = incomeMap.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    final colors = [
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.tertiaryContainer,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primaryContainer,
    ];

    final List<CategoryIncomeData> result = [];
    int index = 0;

    incomeMap.forEach((category, amount) {
      result.add(
        CategoryIncomeData(
          category: category,
          amount: amount,
          percentage: totalIncome > 0 ? (amount / totalIncome) * 100 : 0,
          color: colors[index % colors.length],
        ),
      );
      index++;
    });

    return result;
  }

  Widget _buildExpenseTrendChart(List<Transaction> transactions) {
    final trendData = _calculateExpenseTrend(transactions);
    final maxValue = trendData.isNotEmpty
        ? trendData.reduce((a, b) => a > b ? a : b)
        : 1.0;

    if (trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('支出趋势', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _getTrendChartWidth(trendData.length),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxValue * 1.8,
                      barGroups: trendData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              color: Theme.of(context).colorScheme.primary,
                              width: 15,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ],
                        );
                      }).toList(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBorderRadius: BorderRadius.circular(15),
                          tooltipPadding: EdgeInsets.all(5),
                          getTooltipColor: (group) {
                            return Theme.of(
                              context,
                            ).colorScheme.primaryContainer;
                          },
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = _getTrendLabel(group.x);
                            final value = rod.toY;
                            return BarTooltipItem(
                              '$label\n¥ ${value.toStringAsFixed(2)}',
                              TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < trendData.length) {
                                return Text(
                                  _getTrendLabel(index),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxValue > 0 ? maxValue / 5 : 1,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const Text('');
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeTrendChart(List<Transaction> transactions) {
    final trendData = _calculateIncomeTrend(transactions);
    final maxValue = trendData.isNotEmpty
        ? trendData.reduce((a, b) => a > b ? a : b)
        : 1.0;

    if (trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('收入趋势', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _getTrendChartWidth(trendData.length),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxValue * 1.8,
                      barGroups: trendData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 15,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ],
                        );
                      }).toList(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBorderRadius: BorderRadius.circular(15),
                          tooltipPadding: EdgeInsets.all(5),
                          getTooltipColor: (group) {
                            return Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer;
                          },
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = _getTrendLabel(group.x);
                            final value = rod.toY;
                            return BarTooltipItem(
                              '$label\n¥ ${value.toStringAsFixed(2)}',
                              TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < trendData.length) {
                                return Text(
                                  _getTrendLabel(index),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxValue > 0 ? maxValue / 5 : 1,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const Text('');
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _calculateExpenseTrend(List<Transaction> transactions) {
    switch (_currentPeriod) {
      case AnalysisPeriod.weekly:
        final dailyExpenses = List<double>.filled(7, 0);
        for (var transaction in transactions) {
          if (transaction.type == TransactionType.expense) {
            final dayOfWeek = transaction.date.weekday - 1;
            if (dayOfWeek >= 0 && dayOfWeek < 7) {
              dailyExpenses[dayOfWeek] += transaction.money;
            }
          }
        }
        return dailyExpenses;

      case AnalysisPeriod.monthly:
        final weeklyExpenses = List<double>.filled(4, 0);
        for (var transaction in transactions) {
          if (transaction.type == TransactionType.expense) {
            final weekOfMonth = ((transaction.date.day - 1) ~/ 7);
            final weekIndex = weekOfMonth < 4 ? weekOfMonth : 3;
            weeklyExpenses[weekIndex] += transaction.money;
          }
        }
        return weeklyExpenses;

      case AnalysisPeriod.yearly:
        final monthlyExpenses = List<double>.filled(12, 0);
        for (var transaction in transactions) {
          if (transaction.type == TransactionType.expense) {
            final monthIndex = transaction.date.month - 1;
            if (monthIndex >= 0 && monthIndex < 12) {
              monthlyExpenses[monthIndex] += transaction.money;
            }
          }
        }
        return monthlyExpenses;
    }
  }

  List<double> _calculateIncomeTrend(List<Transaction> transactions) {
    switch (_currentPeriod) {
      case AnalysisPeriod.weekly:
        final dailyIncomes = List<double>.filled(7, 0);
        for (var transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            final dayOfWeek = transaction.date.weekday - 1;
            if (dayOfWeek >= 0 && dayOfWeek < 7) {
              dailyIncomes[dayOfWeek] += transaction.money;
            }
          }
        }
        return dailyIncomes;

      case AnalysisPeriod.monthly:
        final weeklyIncomes = List<double>.filled(4, 0);
        for (var transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            final weekOfMonth = ((transaction.date.day - 1) ~/ 7);
            final weekIndex = weekOfMonth < 4 ? weekOfMonth : 3;
            weeklyIncomes[weekIndex] += transaction.money;
          }
        }
        return weeklyIncomes;

      case AnalysisPeriod.yearly:
        final monthlyIncomes = List<double>.filled(12, 0);
        for (var transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            final monthIndex = transaction.date.month - 1;
            if (monthIndex >= 0 && monthIndex < 12) {
              monthlyIncomes[monthIndex] += transaction.money;
            }
          }
        }
        return monthlyIncomes;
    }
  }

  double _getTrendChartWidth(int dataCount) {
    final minWidth = 300.0;
    final calculatedWidth = (dataCount * 60).toDouble();
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  String _getTrendLabel(int index) {
    switch (_currentPeriod) {
      case AnalysisPeriod.weekly:
        final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return index < weekdays.length ? weekdays[index] : '';

      case AnalysisPeriod.monthly:
        return '第${index + 1}周';

      case AnalysisPeriod.yearly:
        final months = [
          '1月',
          '2月',
          '3月',
          '4月',
          '5月',
          '6月',
          '7月',
          '8月',
          '9月',
          '10月',
          '11月',
          '12月',
        ];
        return index < months.length ? months[index] : '';
    }
  }

  List<Transaction> _filterTransactionsByPeriod(AnalysisPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case AnalysisPeriod.weekly:
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day - now.weekday + 1,
        );
        final weekEnd = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + 7,
        );
        return _transactions
            .where((t) => t.date.isAfter(weekStart) && t.date.isBefore(weekEnd))
            .toList();

      case AnalysisPeriod.monthly:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1);
        return _transactions
            .where(
              (t) => t.date.isAfter(monthStart) && t.date.isBefore(monthEnd),
            )
            .toList();

      case AnalysisPeriod.yearly:
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year + 1, 1, 1);
        return _transactions
            .where((t) => t.date.isAfter(yearStart) && t.date.isBefore(yearEnd))
            .toList();
    }
  }

  AnalysisStats _calculateStatistics(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.money;
        incomeCount++;
      } else {
        totalExpense += transaction.money;
        expenseCount++;
      }
    }

    return AnalysisStats(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
      netIncome: totalIncome - totalExpense,
    );
  }

  Widget _buildOverviewCard(AnalysisStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _getPeriodTitle(_currentPeriod),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  '收入',
                  '¥ ${stats.totalIncome.toStringAsFixed(2)}',
                  Theme.of(context).colorScheme.tertiary,
                ),
                _buildStatItem(
                  '支出',
                  '¥ ${stats.totalExpense.toStringAsFixed(2)}',
                  Theme.of(context).colorScheme.primary,
                ),
                _buildStatItem(
                  '净收入',
                  '¥ ${stats.netIncome.toStringAsFixed(2)}',
                  stats.netIncome >= 0
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildIncomeExpenseChart(AnalysisStats stats) {
    final maxValue = [
      stats.totalIncome,
      stats.totalExpense,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('收支对比', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxValue * 1.8,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: stats.totalIncome,
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 15,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: stats.totalExpense,
                          color: Theme.of(context).colorScheme.primary,
                          width: 15,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorderRadius: BorderRadius.circular(15),
                      tooltipPadding: EdgeInsets.all(5),
                      getTooltipColor: (group) {
                        return group.x == 0
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.primaryContainer;
                      },
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = groupIndex == 0 ? '收入' : '支出';
                        final value = rod.toY;
                        Color textColor = groupIndex == 0
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.primary;
                        return BarTooltipItem(
                          '$label\n¥ ${value.toStringAsFixed(2)}',
                          TextStyle(color: textColor, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(
                                '收入',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              );
                            case 1:
                              return Text(
                                '支出',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxValue > 0 ? maxValue / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryExpenseChart(List<Transaction> transactions) {
    final categoryData = _calculateCategoryExpense(transactions);

    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('支出分类', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData
                      .map(
                        (data) => PieChartSectionData(
                          value: data.amount,
                          title:
                              '${data.category}\n${data.percentage.toStringAsFixed(1)} %',
                          titleStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          color: data.color,
                          showTitle: true,
                        ),
                      )
                      .toList(),
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categoryData
                  .map(
                    (data) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.category}: ¥ ${data.amount.toStringAsFixed(2)} (${data.percentage.toStringAsFixed(1)}%)',
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryExpenseData> _calculateCategoryExpense(
    List<Transaction> transactions,
  ) {
    final expenseMap = <String, double>{};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final category = _getCategoryName(transaction.name);
        expenseMap[category] = (expenseMap[category] ?? 0) + transaction.money;
      }
    }

    if (expenseMap.isEmpty) {
      return [];
    }

    final totalExpense = expenseMap.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.tertiaryContainer,
    ];

    final List<CategoryExpenseData> result = [];
    int index = 0;

    expenseMap.forEach((category, amount) {
      result.add(
        CategoryExpenseData(
          category: category,
          amount: amount,
          percentage: totalExpense > 0 ? (amount / totalExpense) * 100 : 0,
          color: colors[index % colors.length],
        ),
      );
      index++;
    });

    return result;
  }

  Widget _buildHighestTransactionsCard(List<Transaction> transactions) {
    final highestIncome = _getHighestIncomeTransaction(transactions);
    final highestExpense = _getHighestExpenseTransaction(transactions);

    if (highestIncome == null && highestExpense == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('最高记录', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (highestIncome != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '最高收入: ¥ ${highestIncome.money.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                  Text(
                    _formatTransactionDate(highestIncome.date),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (highestExpense != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.trending_down,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '最高支出: ¥ ${highestExpense.money.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    _formatTransactionDate(highestExpense.date),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Transaction? _getHighestIncomeTransaction(List<Transaction> transactions) {
    Transaction? highest;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        if (highest == null || transaction.money > highest.money) {
          highest = transaction;
        }
      }
    }
    return highest;
  }

  Transaction? _getHighestExpenseTransaction(List<Transaction> transactions) {
    Transaction? highest;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        if (highest == null || transaction.money > highest.money) {
          highest = transaction;
        }
      }
    }
    return highest;
  }

  String _formatTransactionDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailedStats(AnalysisStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('详细统计', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            _buildDetailRow('收入笔数', '${stats.incomeCount} 笔'),
            _buildDetailRow('支出笔数', '${stats.expenseCount} 笔'),
            _buildDetailRow(
              '平均收入',
              stats.incomeCount > 0
                  ? '¥ ${(stats.totalIncome / stats.incomeCount).toStringAsFixed(2)}'
                  : '¥ 0.00',
            ),
            _buildDetailRow(
              '平均支出',
              stats.expenseCount > 0
                  ? '¥ ${(stats.totalExpense / stats.expenseCount).toStringAsFixed(2)}'
                  : '¥ 0.00',
            ),
            _buildDetailRow(
              '结余率',
              stats.totalIncome > 0
                  ? '${((stats.netIncome / stats.totalIncome) * 100).toStringAsFixed(1)}%'
                  : '0.0%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _getPeriodTitle(AnalysisPeriod period) {
    switch (period) {
      case AnalysisPeriod.weekly:
        return '本周分析';
      case AnalysisPeriod.monthly:
        return '本月分析';
      case AnalysisPeriod.yearly:
        return '本年分析';
    }
  }
}

enum AnalysisPeriod { weekly, monthly, yearly }

class AnalysisStats {
  final double totalIncome;
  final double totalExpense;
  final int incomeCount;
  final int expenseCount;
  final double netIncome;

  AnalysisStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeCount,
    required this.expenseCount,
    required this.netIncome,
  });
}

class CategoryExpenseData {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  CategoryExpenseData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class CategoryIncomeData {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  CategoryIncomeData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
