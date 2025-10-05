import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/views/home_page/alt_dialogs/category_chip_widget.dart';
import 'package:jiyi/services/database_service.dart';

class AltDialogWidget extends StatefulWidget {
  final String title;
  final Transaction? transaction;

  const AltDialogWidget({super.key, required this.title, this.transaction});

  @override
  State<AltDialogWidget> createState() => _AltDialogWidgetState();
}

class _AltDialogWidgetState extends State<AltDialogWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late DateTime _selectedDate;

  late TransactionType _transactionType;

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.transaction != null) {
      _nameController.text = widget.transaction!.name;
      _moneyController.text = widget.transaction!.money.toString();
      _selectedDate = widget.transaction!.date;
      _transactionType = widget.transaction!.type;
    } else {
      _nameController.text = '';
      _moneyController.text = '';
      _selectedDate = DateTime.now();
      _transactionType = TransactionType.expense;
    }
    _dateController.text = _formatDate(_selectedDate);
  }

  Future<void> _loadCategories() async {
    try {
      final transactions = await DatabaseService.instance.getTransactions();
      final Set<String> categoriesSet = <String>{};

      for (var transaction in transactions) {
        if (transaction.name.contains('-')) {
          final category = transaction.name.split('-').first;
          if (category.isNotEmpty) {
            categoriesSet.add(category);
          }
        }
      }

      setState(() {
        _categories = categoriesSet.toList()..sort();
      });
    } catch (e) {
      debugPrint('加载分类失败: $e');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy年M月d日 HH点mm分').format(date);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _moneyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  bool iconColor = true;

  void _addCategoryToNameField(String category) {
    setState(() {
      String currentText = _nameController.text;

      if (currentText.contains('-')) {
        final parts = currentText.split('-');
        if (parts.length > 1) {
          _nameController.text = '$category-${parts.sublist(1).join('-')}';
        } else {
          _nameController.text = '$category-';
        }
      } else {
        _nameController.text = '$category-$currentText';
      }

      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: Column(
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text('类型'),
              SegmentedButton<TransactionType>(
                selectedIcon: Icon(
                  Icons.check_circle,
                  color: iconColor
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
                ),
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    icon: Icon(Icons.money),
                    label: Text('支出'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    icon: Icon(Icons.wallet),
                    label: Text('收入'),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                    iconColor = !iconColor;
                  });
                },
              ),
            ],
          ),
          Divider(),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '名称',
              border: OutlineInputBorder(),
              hintText: '请输入名称, 如冰红茶',
            ),
          ),
          TextField(
            controller: _moneyController,
            decoration: InputDecoration(
              labelText: '金额',
              border: OutlineInputBorder(),
              hintText: '请输入金额, 如2 / 2.5',
            ),
            keyboardType: TextInputType.number,
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text('分类')],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 5,
              children: _categories.isEmpty
                  ? [
                      Text(
                        '暂无分类',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ]
                  : _categories.map((category) {
                      return CategoryChipWidget(
                        title: category,
                        onTap: () => _addCategoryToNameField(category),
                      );
                    }).toList(),
            ),
          ),
          Divider(),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '时间',
              prefixIcon: Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.outline,
              ),
              border: OutlineInputBorder(),
            ),
            onTap: _selectDateTime,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('取消')),
        FilledButton(onPressed: _saveTransaction, child: Text('保存')),
      ],
    );
  }

  void _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = _formatDate(_selectedDate);
        });
      }
    }
  }

  void _saveTransaction() {
    if (_moneyController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写金额')));
      return;
    }

    try {
      double money = double.parse(_moneyController.text);

      Transaction transaction = Transaction(
        id: widget.transaction?.id,
        name: _nameController.text.isEmpty ? '未命名账目' : _nameController.text,
        money: money,
        date: _selectedDate,
        type: _transactionType,
      );

      Navigator.pop(context, transaction);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('金额格式错误')));
    }
  }
}
