import 'package:flutter/material.dart';
import 'package:jiyi/widgets/drawer/drawer_widget.dart';
import 'package:jiyi/widgets/item/item_list_widget.dart';
import 'package:jiyi/widgets/btm_appbar_widget.dart';
import 'package:jiyi/widgets/fab_widget.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';
import 'package:jiyi/widgets/alt_dialog_widget.dart'; // 添加这个导入

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabaseAndLoadData();
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
              ),
      ),
      bottomNavigationBar: BtmAppbarWidget(),
      floatingActionButton: Fab(onTransactionAdded: _loadTransactions),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      drawer: DrawerWidget(),
    );
  }
}
