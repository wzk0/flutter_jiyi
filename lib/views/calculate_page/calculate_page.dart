import 'package:flutter/material.dart';

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _input = '0';
  String _expression = '';
  double _result = 0;
  bool _isNewInput = true;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        // 清除所有
        _input = '0';
        _expression = '';
        _result = 0;
        _isNewInput = true;
      } else if (buttonText == 'C') {
        // 清除当前输入
        _input = '0';
        _isNewInput = true;
      } else if (buttonText == '⌫') {
        // 退格
        if (_input.length > 1) {
          _input = _input.substring(0, _input.length - 1);
        } else {
          _input = '0';
        }
      } else if (buttonText == '=') {
        // 计算结果
        try {
          if (_expression.isNotEmpty) {
            String fullExpression = _expression + _input;
            _result = _evaluateExpression(fullExpression);
            _input = _formatResult(_result);
            _expression = '';
          }
          _isNewInput = true;
        } catch (e) {
          _input = '错误';
          _expression = '';
          _isNewInput = true;
        }
      } else if (['+', '-', '×', '÷'].contains(buttonText)) {
        // 运算符
        try {
          if (_expression.isNotEmpty && !_isNewInput) {
            // 连续运算符处理
            String fullExpression = _expression + _input;
            _result = _evaluateExpression(fullExpression);
            _input = _formatResult(_result);
            _expression = _input + _mapOperator(buttonText);
          } else if (_expression.isEmpty) {
            // 第一次输入运算符
            _expression = _input + _mapOperator(buttonText);
          } else {
            // 继续添加运算符
            _expression += _input + _mapOperator(buttonText);
          }
          _isNewInput = true;
        } catch (e) {
          _input = '错误';
          _expression = '';
          _isNewInput = true;
        }
      } else if (buttonText == '.') {
        // 小数点
        if (_isNewInput) {
          _input = '0.';
          _isNewInput = false;
        } else if (!_input.contains('.')) {
          _input += '.';
        }
      } else if (buttonText == '±') {
        // 正负号
        if (_input != '0') {
          if (_input.startsWith('-')) {
            _input = _input.substring(1);
          } else {
            _input = '-$_input';
          }
        }
      } else {
        // 数字
        if (_isNewInput) {
          _input = buttonText;
          _isNewInput = false;
        } else {
          if (_input == '0') {
            _input = buttonText;
          } else {
            _input += buttonText;
          }
        }
      }
    });
  }

  String _mapOperator(String op) {
    switch (op) {
      case '×':
        return '*';
      case '÷':
        return '/';
      default:
        return op;
    }
  }

  double _evaluateExpression(String expression) {
    try {
      // 简单的表达式计算
      return _calculate(expression);
    } catch (e) {
      throw Exception('计算错误');
    }
  }

  // 简单的表达式计算器 - 修复版本
  double _calculate(String expression) {
    // 移除空格
    expression = expression.replaceAll(' ', '');

    // 检查表达式是否以运算符结尾
    if (expression.endsWith('+') ||
        expression.endsWith('-') ||
        expression.endsWith('*') ||
        expression.endsWith('/')) {
      // 移除末尾的运算符
      expression = expression.substring(0, expression.length - 1);
    }

    // 如果表达式为空或只有运算符，返回0
    if (expression.isEmpty ||
        expression == '+' ||
        expression == '-' ||
        expression == '*' ||
        expression == '/') {
      return 0;
    }

    // 使用两个列表分别存储数字和操作符
    List<double> numbers = [];
    List<String> operators = [];

    // 解析表达式
    String currentNumber = '';
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if (char == '+' || char == '-' || char == '*' || char == '/') {
        if (currentNumber.isEmpty) {
          if (char == '-') {
            currentNumber = '-';
          } else {
            // 连续运算符，跳过
            continue;
          }
        } else {
          numbers.add(double.parse(currentNumber));
          currentNumber = '';
          operators.add(char);
        }
      } else {
        currentNumber += char;
      }
    }

    // 添加最后一个数字
    if (currentNumber.isNotEmpty) {
      numbers.add(double.parse(currentNumber));
    }

    // 如果没有数字，返回0
    if (numbers.isEmpty) {
      return 0;
    }

    // 先计算乘除
    for (int i = 0; i < operators.length; i++) {
      if (operators[i] == '*' || operators[i] == '/') {
        if (i + 1 < numbers.length) {
          double result;
          if (operators[i] == '*') {
            result = numbers[i] * numbers[i + 1];
          } else {
            if (numbers[i + 1] == 0) {
              throw Exception('除零错误');
            }
            result = numbers[i] / numbers[i + 1];
          }
          numbers[i] = result;
          numbers.removeAt(i + 1);
          operators.removeAt(i);
          i--;
        }
      }
    }

    // 再计算加减
    double result = numbers[0];
    for (int i = 0; i < operators.length; i++) {
      if (i + 1 < numbers.length) {
        if (operators[i] == '+') {
          result += numbers[i + 1];
        } else if (operators[i] == '-') {
          result -= numbers[i + 1];
        }
      }
    }

    return result;
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      // 保留合适的小数位数
      String str = value.toString();
      if (str.length > 10) {
        return value.toStringAsFixed(8);
      }
      return str;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // 显示区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 表达式显示
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // 当前输入显示
                  Text(
                    _input,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // 按钮区域
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行按钮
                _buildButtonRow([
                  CalculatorButton(
                    text: 'AC',
                    type: ButtonType.function,
                    onPressed: () => _onButtonPressed('AC'),
                  ),
                  CalculatorButton(
                    text: 'C',
                    type: ButtonType.function,
                    onPressed: () => _onButtonPressed('C'),
                  ),
                  CalculatorButton(
                    text: '⌫',
                    type: ButtonType.function,
                    onPressed: () => _onButtonPressed('⌫'),
                  ),
                  CalculatorButton(
                    text: '÷',
                    type: ButtonType.operator,
                    onPressed: () => _onButtonPressed('÷'),
                  ),
                ]),
                // 数字按钮行
                _buildButtonRow([
                  CalculatorButton(
                    text: '7',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('7'),
                  ),
                  CalculatorButton(
                    text: '8',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('8'),
                  ),
                  CalculatorButton(
                    text: '9',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('9'),
                  ),
                  CalculatorButton(
                    text: '×',
                    type: ButtonType.operator,
                    onPressed: () => _onButtonPressed('×'),
                  ),
                ]),
                _buildButtonRow([
                  CalculatorButton(
                    text: '4',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('4'),
                  ),
                  CalculatorButton(
                    text: '5',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('5'),
                  ),
                  CalculatorButton(
                    text: '6',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('6'),
                  ),
                  CalculatorButton(
                    text: '-',
                    type: ButtonType.operator,
                    onPressed: () => _onButtonPressed('-'),
                  ),
                ]),
                _buildButtonRow([
                  CalculatorButton(
                    text: '1',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('1'),
                  ),
                  CalculatorButton(
                    text: '2',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('2'),
                  ),
                  CalculatorButton(
                    text: '3',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('3'),
                  ),
                  CalculatorButton(
                    text: '+',
                    type: ButtonType.operator,
                    onPressed: () => _onButtonPressed('+'),
                  ),
                ]),
                _buildButtonRow([
                  CalculatorButton(
                    text: '±',
                    type: ButtonType.function,
                    onPressed: () => _onButtonPressed('±'),
                  ),
                  CalculatorButton(
                    text: '0',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('0'),
                  ),
                  CalculatorButton(
                    text: '.',
                    type: ButtonType.number,
                    onPressed: () => _onButtonPressed('.'),
                  ),
                  CalculatorButton(
                    text: '=',
                    type: ButtonType.equals,
                    onPressed: () => _onButtonPressed('='),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

enum ButtonType { number, operator, function, equals }

class CalculatorButton extends StatelessWidget {
  final String text;
  final ButtonType type;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color foregroundColor;

    switch (type) {
      case ButtonType.number:
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurfaceVariant;
        break;
      case ButtonType.operator:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case ButtonType.function:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case ButtonType.equals:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: AspectRatio(
          aspectRatio: 1,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: onPressed,
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
