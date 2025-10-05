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
import 'package:shared_preferences/shared_preferences.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<Transaction> _searchResults = [];

  bool _showYearDivider = false;
  bool _showMonthDivider = false;
  bool _showDayDivider = false;

  @override
  void initState() {
    super.initState();
    _initDatabaseAndLoadData();
    _loadDividerSettings();
  }

  Future<void> _loadDividerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showYearDivider = prefs.getBool('show_year_divider') ?? false;
      _showMonthDivider = prefs.getBool('show_month_divider') ?? false;
      _showDayDivider = prefs.getBool('show_day_divider') ?? false;
    });
  }

  (double, double) _calculateMinMaxAmount(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return (0.0, 100.0);
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

    if (minAmount == maxAmount) {
      maxAmount = minAmount + 100;
    }

    return (minAmount, maxAmount);
  }

  Future<void> _initDatabaseAndLoadData() async {
    try {
      await DatabaseService.instance.database;

      await _loadTransactions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('数据库初始化失败: $e');
    }
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
      debugPrint('加载数据失败: $e');
    }
  }

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

  Future<void> _updateTransaction(Transaction transaction) async {
    try {
      await DatabaseService.instance.updateTransaction(transaction);
      await _loadTransactions();
      await _loadDividerSettings();
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

  Future<void> _performDelete(String id) async {
    try {
      await DatabaseService.instance.deleteTransaction(id);
      await _loadTransactions();
      await _loadDividerSettings();
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

  void _performSearch(Map<String, dynamic> searchCriteria) {
    setState(() {
      _isSearching = true;
      _searchResults = _filterTransactions(_transactions, searchCriteria);
    });
  }

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
      if (keyword.isNotEmpty &&
          !transaction.name.toLowerCase().contains(keyword.toLowerCase())) {
        return false;
      }

      if (transaction.money < minAmount || transaction.money > maxAmount) {
        return false;
      }

      if (type == 'income' && transaction.type != TransactionType.income) {
        return false;
      }
      if (type == 'expense' && transaction.type != TransactionType.expense) {
        return false;
      }

      if (startDate != null && transaction.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.date.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

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
