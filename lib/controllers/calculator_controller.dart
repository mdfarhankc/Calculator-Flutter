import 'package:math_expressions/math_expressions.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';

final logger = Logger();
const String historyBoxName = 'historyBox';

class CalculatorController {
  String expression = '';
  String result = '0';
  bool hasResult = false;
  List<Map<String, String>> history = [];

  CalculatorController() {
    loadHistory();
  }

  //   --------------- Calculator Operations ----------------
  void clear() {
    expression = '';
    result = '0';
    hasResult = false;
    logger.i('All Cleared!');
  }

  void deleteLast() {
    if (expression.isEmpty) return;
    expression = expression.substring(0, expression.length - 1);
    logger.d('Deleted last character');
  }

  void append(String value) {
    expression += value;
    logger.d('Append: $value');
  }

  void toggleSign() {
    if (expression.isEmpty) return;
    expression =
        expression.startsWith('-') ? expression.substring(1) : '-$expression';
    logger.d('Toggle sign!');
  }

  void applyPercentage() {
    if (expression.isEmpty) return;
    try {
      final val = double.parse(expression) / 100;
      expression = val.toString();
      hasResult = true;
      logger.d('Percentage applied');
    } catch (_) {
      logger.e('Invalid percentage calculation');
    }
  }

  void calculateResult() {
    try {
      final parsedExp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      GrammarParser parser = GrammarParser();
      Expression exp = parser.parse(parsedExp);
      ContextModel contextModel = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, contextModel);
      result = eval.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
      saveHistory(expression, result);
      expression = '';
      hasResult = true;
      logger.i('Result calculated: $result');
    } catch (e) {
      result = 'Error';
      logger.e('Error calculating result: $e');
    }
  }

  //   --------------- History Operations ----------------
  Future<void> saveHistory(String exp, String res) async {
    final box = Hive.box(historyBoxName);
    final record = {'expression': exp, 'result': res};
    box.add(record);
    logger.i("Saved to history: $record");
    loadHistory();
  }

  Future<void> loadHistory() async {
    final box = Hive.box(historyBoxName);
    history =
        box.values
            .map((e) => Map<String, String>.from(e as Map))
            .toList()
            .reversed
            .toList();
    logger.d('Loaded history: $history');
  }

  Future<void> clearHistory() async {
    final box = Hive.box(historyBoxName);
    await box.clear();
    history.clear();
    logger.i('History cleared');
  }
}
