import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiyi/models/transaction.dart';
import 'package:jiyi/services/database_service.dart';

class AIAnalysisService {
  static final AIAnalysisService instance = AIAnalysisService._init();
  AIAnalysisService._init();

  static const String _apiKeyKey = 'qwen_api_key';
  static const String _apiUrl =
      'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation';

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> getApiKey() {
    final prefs = SharedPreferences.getInstance();
    return prefs.then((value) => value.getString(_apiKeyKey));
  }

  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<String> generateAnalysis() async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key 未设置');
    }

    final transactions = await DatabaseService.instance.getTransactions();
    if (transactions.isEmpty) {
      return '没有账目数据可供分析。';
    }

    final prompt = _buildPrompt(transactions);

    final response = await _callQwenAPI(apiKey, prompt);

    if (response.statusCode == 200) {
      final json = response.body;
      final data = jsonDecode(json);
      final text = data['output']['text'] as String?;
      if (text != null) {
        return text;
      } else {
        throw Exception('API 响应中未找到分析文本');
      }
    } else {
      throw Exception('API 请求失败: ${response.body}');
    }
  }

  String _buildPrompt(List<Transaction> transactions) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    int incomeCount = 0;
    int expenseCount = 0;
    final categoryStats = <String, Map<String, double>>{};

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.money;
        incomeCount++;
      } else {
        totalExpense += t.money;
        expenseCount++;
      }
      final nameParts = t.name.split('-');
      final category = nameParts.length > 1 ? nameParts[0] : '未分类';
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {'income': 0.0, 'expense': 0.0};
      }
      if (t.type == TransactionType.income) {
        categoryStats[category]!['income'] =
            categoryStats[category]!['income']! + t.money;
      } else {
        categoryStats[category]!['expense'] =
            categoryStats[category]!['expense']! + t.money;
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('你是一个专业的财务分析师。请基于以下账目数据，给出简洁、有洞察力的分析和建议。');
    buffer.writeln('---');
    buffer.writeln('数据概览:');
    buffer.writeln(
      '  - 总收入: ¥${totalIncome.toStringAsFixed(2)} (共 $incomeCount 笔)',
    );
    buffer.writeln(
      '  - 总支出: ¥${totalExpense.toStringAsFixed(2)} (共 $expenseCount 笔)',
    );
    buffer.writeln(
      '  - 净资产变化: ¥${(totalIncome - totalExpense).toStringAsFixed(2)}',
    );
    buffer.writeln('');
    buffer.writeln('分类支出详情 (支出):');
    categoryStats.forEach((category, stats) {
      if (stats['expense']! > 0) {
        buffer.writeln(
          '  - $category: ¥${stats['expense']!.toStringAsFixed(2)}',
        );
      }
    });
    buffer.writeln('');
    buffer.writeln('分类收入详情 (收入):');
    categoryStats.forEach((category, stats) {
      if (stats['income']! > 0) {
        buffer.writeln(
          '  - $category: ¥${stats['income']!.toStringAsFixed(2)}',
        );
      }
    });
    buffer.writeln('');
    buffer.writeln('请分析:');
    buffer.writeln('1. 指出主要的支出/收入类别/条目，并评估其合理性。');
    buffer.writeln('2. 指出主要的收入来源。');
    buffer.writeln('3. 识别任何潜在的财务风险或值得关注的趋势。');
    buffer.writeln('4. 提供 2-3 条具体的、可操作的财务优化建议。');
    buffer.writeln('5. 其他更多你想补充的点.');
    buffer.writeln('---');
    buffer.writeln('请用中文回复，语言简洁明了，重点突出。(不要使用markdown格式)');

    return buffer.toString();
  }

  Future<http.Response> _callQwenAPI(String apiKey, String prompt) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": "qwen-max",
      "input": {
        "messages": [
          {"role": "system", "content": "你是一个专业的财务分析师。请根据用户提供的账目数据进行分析并给出建议。"},
          {"role": "user", "content": prompt},
        ],
      },
      "parameters": {},
    });

    return await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
  }
}
