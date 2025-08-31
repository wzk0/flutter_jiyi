import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/widgets/drawer/drawer_title_widget.dart';
import 'package:jiyi/widgets/drawer/expd_card/expd_card_highest_widget.dart';
import 'package:jiyi/widgets/drawer/expd_card/expd_card_listtile_widget.dart';
import 'package:jiyi/widgets/drawer/expd_card/expd_card_widget.dart';
import 'package:jiyi/widgets/tag_widget.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SafeArea(
            minimum: EdgeInsets.all(10),
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(),
                Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: Text('今日'),
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
                              '¥ 30',
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
                              '¥ 70',
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
                      child: PieChart(
                        PieChartData(
                          //centerSpaceRadius: 5,
                          sections: [
                            PieChartSectionData(
                              value: 70,
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 30,
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                DrawerTitleWidget(actions: '统计'),
                Row(
                  children: [
                    ExpdCardWidget(
                      bgcolor: Theme.of(context).colorScheme.tertiaryContainer,
                      child: ExpdCardListtileWidget(
                        title: '¥ 100.00',
                        subtitle: '共 10 笔',
                        leading: '收入',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ExpdCardWidget(
                      bgcolor: Theme.of(context).colorScheme.primaryContainer,
                      child: ExpdCardListtileWidget(
                        title: '¥ 100.00',
                        subtitle: '共 10 笔',
                        leading: '支出',
                      ),
                    ),
                  ],
                ),
                Divider(),
                DrawerTitleWidget(actions: '至今'),
                Row(
                  spacing: 5,
                  children: [
                    ExpdCardHighestWidget(
                      money: 200,
                      descr: '最高的一笔收入',
                      bgcolor: Theme.of(context).colorScheme.tertiaryContainer,
                      txcolor: Theme.of(context).colorScheme.tertiary,
                    ),
                    ExpdCardHighestWidget(
                      money: 100,
                      descr: '最高的一笔支出',
                      bgcolor: Theme.of(context).colorScheme.primaryContainer,
                      txcolor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                Divider(),
                DrawerTitleWidget(actions: '操作'),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: Icon(Icons.data_array),
                  label: Text('数据管理'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: Icon(Icons.lightbulb),
                  label: Text('智能分析'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
