import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchDialogWidget extends StatefulWidget {
  final double minAmount;
  final double maxAmount;

  const SearchDialogWidget({
    super.key,
    required this.minAmount,
    required this.maxAmount,
  });

  @override
  State<SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<SearchDialogWidget> {
  late RangeValues _amountRange;
  String _radioValue = 'all'; // 'all', 'income', 'expense'
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化金额范围为传入的最小最大值
    _amountRange = RangeValues(widget.minAmount, widget.maxAmount);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  // 选择开始日期
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        // 确保结束日期不早于开始日期
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  // 选择结束日期
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
        // 确保开始日期不晚于结束日期
        if (_startDate != null && _startDate!.isAfter(_endDate!)) {
          _startDate = _endDate;
        }
      });
    }
  }

  // 格式化日期显示
  String _formatDate(DateTime? date) {
    if (date == null) return '未选择';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('搜索'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 关键词输入
            TextField(
              controller: _keywordController,
              decoration: InputDecoration(
                labelText: '关键词',
                hintText: '请输入关键词',
                border: OutlineInputBorder(),
              ),
            ),
            Divider(height: 30),

            // 金额范围
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('金额范围'),
                const SizedBox(height: 8),
                RangeSlider(
                  labels: RangeLabels(
                    _amountRange.start.toStringAsFixed(2),
                    _amountRange.end.toStringAsFixed(2),
                  ),
                  values: _amountRange,
                  onChanged: (value) {
                    setState(() {
                      _amountRange = value;
                    });
                  },
                  min: widget.minAmount,
                  max: widget.maxAmount,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '[ ¥ ${_amountRange.start.toStringAsFixed(2)} ~ ${_amountRange.end.toStringAsFixed(2)} ]',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(height: 30),
            // 类型选择 - 优化样式
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text('统计范围')],
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('全部')),
                    ButtonSegment(value: 'income', label: Text('收入')),
                    ButtonSegment(value: 'expense', label: Text('支出')),
                  ],
                  selected: {_radioValue},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _radioValue = newSelection.first;
                    });
                  },
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //iconSize: WidgetStatePropertyAll(1),
                  ),
                  showSelectedIcon: false,
                ),
              ],
            ),
            Divider(height: 30),
            // 日期范围选择
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('日期范围'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('开始日期', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          FilledButton.tonal(
                            onPressed: _selectStartDate,
                            child: Text(
                              _formatDate(_startDate),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('结束日期', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          FilledButton.tonal(
                            onPressed: _selectEndDate,
                            child: Text(
                              _formatDate(_endDate),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('取消')),
        FilledButton(
          onPressed: () {
            // 返回搜索条件
            Navigator.pop(context, {
              'keyword': _keywordController.text,
              'minAmount': _amountRange.start,
              'maxAmount': _amountRange.end,
              'type': _radioValue,
              'startDate': _startDate,
              'endDate': _endDate,
            });
          },
          child: Text('搜索'),
        ),
      ],
    );
  }
}
