import 'package:flutter/material.dart';
import 'package:jiyi/views/home_page/drawer/drawer_widget.dart';
import 'package:jiyi/views/home_page/item/item_list_widget.dart';
import 'package:jiyi/views/home_page/btm_appbar_widget.dart';
import 'package:jiyi/views/home_page/fab_widget.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:jiyi/views/home_page/alt_dialog_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 添加这个导入

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('记易'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ItemListWidget(
                transactions: _transactions,
                onEdit: _editTransaction, // 传递编辑回调
                onDelete: _deleteTransaction, // 传递删除回调
                showYearDivider: _showYearDivider, // 传递分割线设置
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
