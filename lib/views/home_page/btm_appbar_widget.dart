import 'package:flutter/material.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/bill_import_service.dart';
import 'package:jiyi/views/analytics_page/analytics_page.dart';
import 'package:jiyi/views/home_page/bill_import_dialog.dart';
import 'package:jiyi/views/settings_page/settings_page.dart';

class BtmAppbarWidget extends StatelessWidget {
  const BtmAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AnalyticsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.analytics),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BillImportDialog(
                  onImport:
                      (
                        List<Transaction> transactions,
                        int successCount,
                        int duplicateCount,
                      ) async {
                        if (transactions.isNotEmpty) {
                          try {
                            final result = await BillImportService.instance
                                .batchInsertTransactions(transactions);
                            int actualSuccessCount = result.successCount;
                            int actualDuplicateCount = result.duplicateCount;
                            String message = '成功导入 $actualSuccessCount 条账目';
                            if (actualDuplicateCount > 0) {
                              message += ', $actualDuplicateCount 条时间戳相同数据未导入';
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('导入失败: $e')),
                              );
                            }
                          }
                        }
                      },
                ),
              );
            },
            icon: Icon(Icons.file_upload),
          ),
        ],
      ),
    );
  }
}
