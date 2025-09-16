import 'package:flutter/material.dart';
import 'package:jiyi/views/calculate_page/calculate_page.dart';
import 'package:jiyi/views/home_page/drawer/drawer_widget.dart';
import 'package:jiyi/views/home_page/item/item_list_widget.dart';
import 'package:jiyi/views/home_page/btm_appbar_widget.dart';
import 'package:jiyi/views/home_page/fab_widget.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:jiyi/views/home_page/alt_dialogs/alt_dialog_widget.dart';
import 'package:jiyi/views/home_page/search_dialog_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 添加这个导入

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isSearching = false; // 添加搜索状态
  List<Transaction> _searchResults = []; // 添加搜索结果

  // 分割线设置
  bool _showYearDivider = false;
  bool _showMonthDivider = false;
  bool _showDayDivider = false;

  @override
  void initState() {
    super.initState();
    _initDatabaseAndLoadData();
    _loadDividerSettings(); // 加载分割线设置
  }

  // 加载分割线设置
  Future<void> _loadDividerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showYearDivider = prefs.getBool('show_year_divider') ?? false;
      _showMonthDivider = prefs.getBool('show_month_divider') ?? false;
      _showDayDivider = prefs.getBool('show_day_divider') ?? false;
    });
  }

  // 计算交易数据中的最小和最大金额
  (double, double) _calculateMinMaxAmount(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return (0.0, 100.0); // 默认范围
    }

    double minAmount = transactions.first.money;
    double maxAmount = transactions.first.money;

    for (var transaction in transactions) {
      if (transaction.money < minAmount) {
        minAmount = transaction.money;
      }
      if (transaction.money > maxAmount) {
        maxAmount = transaction.money;
      }
    }

    // 确保有一个合理的范围
    if (minAmount == maxAmount) {
      maxAmount = minAmount + 100; // 如果只有一个值，扩展范围
    }

    return (minAmount, maxAmount);
  }

  // 初始化数据库并加载数据
  Future<void> _initDatabaseAndLoadData() async {
    try {
      // 确保数据库初始化
      await DatabaseService.instance.database;

      // 加载数据
      await _loadTransactions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('数据库初始化失败: $e');
    }
  }

  // 加载交易数据
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
      debugPrint('加载数据失败: $e');
    }
  }

  // 编辑交易
  void _editTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) =>
          AltDialogWidget(title: '编辑记录', transaction: transaction),
    ).then((result) {
      if (result != null) {
        _updateTransaction(result);
      }
    });
  }

  // 更新交易
  Future<void> _updateTransaction(Transaction transaction) async {
    try {
      await DatabaseService.instance.updateTransaction(transaction);
      await _loadTransactions(); // 重新加载数据
      await _loadDividerSettings(); // 重新加载设置（如果有更新）
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新成功')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
      }
    }
  }

  // 删除交易
  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除 "${transaction.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(transaction.id);
            },
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  // 执行删除操作
  Future<void> _performDelete(String id) async {
    try {
      await DatabaseService.instance.deleteTransaction(id);
      await _loadTransactions(); // 重新加载数据
      await _loadDividerSettings(); // 重新加载设置（如果有更新）
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除成功')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  // 显示搜索对话框
  void _showSearchDialog() async {
    final (minAmount, maxAmount) = _calculateMinMaxAmount(_transactions);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          SearchDialogWidget(minAmount: minAmount, maxAmount: maxAmount),
    );

    if (result != null) {
      _performSearch(result);
    }
  }

  // 执行搜索
  void _performSearch(Map<String, dynamic> searchCriteria) {
    setState(() {
      _isSearching = true;
      _searchResults = _filterTransactions(_transactions, searchCriteria);
    });
  }

  // 过滤交易数据
  List<Transaction> _filterTransactions(
    List<Transaction> transactions,
    Map<String, dynamic> criteria,
  ) {
    String keyword = criteria['keyword'] as String? ?? '';
    double minAmount = criteria['minAmount'] as double? ?? 0;
    double maxAmount = criteria['maxAmount'] as double? ?? double.infinity;
    String type = criteria['type'] as String? ?? 'all';
    DateTime? startDate = criteria['startDate'] as DateTime?;
    DateTime? endDate = criteria['endDate'] as DateTime?;

    return transactions.where((transaction) {
      // 关键词过滤
      if (keyword.isNotEmpty &&
          !transaction.name.toLowerCase().contains(keyword.toLowerCase())) {
        return false;
      }

      // 金额范围过滤
      if (transaction.money < minAmount || transaction.money > maxAmount) {
        return false;
      }

      // 类型过滤
      if (type == 'income' && transaction.type != TransactionType.income) {
        return false;
      }
      if (type == 'expense' && transaction.type != TransactionType.expense) {
        return false;
      }

      // 日期范围过滤
      if (startDate != null && transaction.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.date.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  // 清除搜索
  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('记易'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CalculatorWidget();
                  },
                ),
              );
            },
            icon: Icon(Icons.calculate),
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            onPressed: _isSearching ? _clearSearch : _showSearchDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isSearching
            ? ItemListWidget(
                transactions: _searchResults,
                onEdit: _editTransaction,
                onDelete: _deleteTransaction,
                showYearDivider: _showYearDivider,
                showMonthDivider: _showMonthDivider,
                showDayDivider: _showDayDivider,
              )
            : ItemListWidget(
                transactions: _transactions,
                onEdit: _editTransaction,
                onDelete: _deleteTransaction,
                showYearDivider: _showYearDivider,
                showMonthDivider: _showMonthDivider,
                showDayDivider: _showDayDivider,
              ),
      ),
      bottomNavigationBar: BtmAppbarWidget(),
      floatingActionButton: Fab(onTransactionAdded: _loadTransactions),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      drawer: DrawerWidget(),
    );
  }
}
