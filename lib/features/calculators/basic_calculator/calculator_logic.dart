import 'dart:convert';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) =>
      CalculationHistory(
        expression: json['expression'] ?? '',
        result: json['result'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
      );
}

class CalculatorLogic {
  String expression = '';
  int cursorIndex = 0;
  String result = '0';
  String lastCalculation = '';
  bool isEvaluated = false;

  // Modes
  bool isDegreeMode = true;
  bool isInverse = false;

  // Memory
  double memory = 0.0;
  
  // History List
  List<CalculationHistory> historyList = [];

  void moveLeft() {
    if (cursorIndex > 0) {
      cursorIndex--;
    }
  }

  void moveRight() {
    if (cursorIndex < expression.length) {
      cursorIndex++;
    }
  }

  void append(String text) {
    if (text == 'C') {
      expression = '';
      cursorIndex = 0;
      result = '0';
      isEvaluated = false;
      return;
    }
    
    if (text == 'AC') {
      expression = '';
      cursorIndex = 0;
      result = '0';
      lastCalculation = '';
      isEvaluated = false;
      return;
    }

    if (text == 'Deg' || text == 'Rad') {
      isDegreeMode = !isDegreeMode;
      autoEvaluate();
      return;
    }

    if (text == 'Inv') {
      isInverse = !isInverse;
      return;
    }

    if (text == '⌫') {
      if (isEvaluated) {
        isEvaluated = false;
        expression = '';
        cursorIndex = 0;
        result = '0';
      } else if (expression.isNotEmpty && cursorIndex > 0) {
        final atomicTokens = [
          'arcsin(', 'arccos(', 'arctan(',
          'asin(', 'acos(', 'atan(',
          'sqrt(', '10^(', 'sin(',
          'cos(', 'tan(', 'log(',
          'e^(', 'ln(', '√('
        ];

        bool deletedAtomic = false;
        for (final token in atomicTokens) {
          if (cursorIndex >= token.length &&
              expression.substring(cursorIndex - token.length, cursorIndex) == token) {
            expression = expression.substring(0, cursorIndex - token.length) + expression.substring(cursorIndex);
            cursorIndex -= token.length;
            deletedAtomic = true;
            break;
          }
        }

        if (!deletedAtomic) {
          expression = expression.substring(0, cursorIndex - 1) + expression.substring(cursorIndex);
          cursorIndex -= 1;
        }
      }
      autoEvaluate();
      return;
    }

    if (text == '()' || text == '( )') {
      if (isEvaluated) {
        expression = '(';
        cursorIndex = 1;
        isEvaluated = false;
        result = '0';
        autoEvaluate();
        return;
      }

      int openParen = '('.allMatches(expression).length;
      int closeParen = ')'.allMatches(expression).length;

      String charBeforeCursor = '';
      if (cursorIndex > 0) {
        charBeforeCursor = expression[cursorIndex - 1];
      }

      bool canClose = openParen > closeParen &&
          charBeforeCursor.isNotEmpty &&
          (RegExp(r'[0-9\.\πe!]').hasMatch(charBeforeCursor) || charBeforeCursor == ')');

      String inserted = canClose ? ')' : '(';
      expression = expression.substring(0, cursorIndex) + inserted + expression.substring(cursorIndex);
      cursorIndex += 1;
      autoEvaluate();
      return;
    }

    // Memory Operations
    if (text == 'M+') {
      evaluate();
      memory += double.tryParse(result) ?? 0;
      return;
    }
    if (text == 'M-') {
      evaluate();
      memory -= double.tryParse(result) ?? 0;
      return;
    }
    if (text == 'MR') {
      String mVal = _formatValue(memory);
      if (isEvaluated) {
        expression = mVal;
        isEvaluated = false;
      } else {
        expression = expression.substring(0, cursorIndex) + mVal + expression.substring(cursorIndex);
        cursorIndex += mVal.length;
      }
      autoEvaluate();
      return;
    }
    if (text == 'MC') {
      memory = 0.0;
      return;
    }

    if (text == '=') {
      if (expression.isNotEmpty) {
        evaluate();
        if (result != 'Error') {
          historyList.insert(0, CalculationHistory(
            expression: expression,
            result: result,
            timestamp: DateTime.now(),
          ));
          if (historyList.length > 100) {
            historyList = historyList.sublist(0, 100);
          }
          saveHistory();
          lastCalculation = '$expression = $result';
          isEvaluated = true;
          cursorIndex = expression.length;
        }
      }
      return;
    }

    // Scientific functions input mapping
    String input = text;
    if (text == '√') {
      input = '√(';
    } else if (text == 'x²') {
      input = '^2';
    } else if (['sin', 'cos', 'tan', 'log', 'ln', 'asin', 'acos', 'atan'].contains(text)) {
      input = '$text(';
    } else if (text == 'eˣ') {
      input = 'e^(';
    } else if (text == '10ˣ') {
      input = '10^(';
    }

    if (isEvaluated) {
      lastCalculation = '$expression = $result';
      isEvaluated = false;
      
      if (['÷', '×', '-', '+', '^', '!'].contains(text)) {
        expression = result + input;
      } else {
        expression = input;
      }
      cursorIndex = expression.length;
      result = '0';
      autoEvaluate();
      return;
    }

    const mainOperators = ['÷', '×', '-', '+', '−', '–'];
    if (mainOperators.contains(text) &&
        cursorIndex > 0 &&
        mainOperators.contains(expression[cursorIndex - 1])) {
      expression = expression.substring(0, cursorIndex - 1) + input + expression.substring(cursorIndex);
      autoEvaluate();
      return;
    }

    expression = expression.substring(0, cursorIndex) + input + expression.substring(cursorIndex);
    cursorIndex += input.length;
    autoEvaluate();
  }

  void insertText(String text) {
    if (text.isEmpty) return;
    if (isEvaluated) {
      expression = text;
      isEvaluated = false;
      cursorIndex = text.length;
      result = '0';
      autoEvaluate();
      return;
    }
    const mainOperators = ['÷', '×', '-', '+', '−', '–'];
    if (mainOperators.contains(text) &&
        cursorIndex > 0 &&
        mainOperators.contains(expression[cursorIndex - 1])) {
      expression = expression.substring(0, cursorIndex - 1) + text + expression.substring(cursorIndex);
      autoEvaluate();
      return;
    }
    expression = expression.substring(0, cursorIndex) + text + expression.substring(cursorIndex);
    cursorIndex += text.length;
    autoEvaluate();
  }

  String _prepareExpression(String expr) {
    if (expr.isEmpty) return '';

    String cleaned = expr;

    // Replace √ with sqrt
    cleaned = cleaned.replaceAll('√', 'sqrt');

    // Replace factorials !
    cleaned = _replaceFactorials(cleaned);
    if (cleaned == 'Error') return 'Error';

    // Replace inverse trig functions
    if (isDegreeMode) {
      cleaned = _transformFunctionCalls(cleaned, 'asin', (arg) => '(arcsin($arg)*57.29577951308232)');
      cleaned = _transformFunctionCalls(cleaned, 'acos', (arg) => '(arccos($arg)*57.29577951308232)');
      cleaned = _transformFunctionCalls(cleaned, 'atan', (arg) => '(arctan($arg)*57.29577951308232)');

      cleaned = _transformFunctionCalls(cleaned, 'sin', (arg) => 'sin(($arg)*0.017453292519943295)');
      cleaned = _transformFunctionCalls(cleaned, 'cos', (arg) => 'cos(($arg)*0.017453292519943295)');
      cleaned = _transformFunctionCalls(cleaned, 'tan', (arg) => 'tan(($arg)*0.017453292519943295)');
    } else {
      cleaned = _transformFunctionCalls(cleaned, 'asin', (arg) => 'arcsin($arg)');
      cleaned = _transformFunctionCalls(cleaned, 'acos', (arg) => 'arccos($arg)');
      cleaned = _transformFunctionCalls(cleaned, 'atan', (arg) => 'arctan($arg)');
    }

    // Replace log(x) [base 10] with (ln(x) / ln(10))
    cleaned = _transformFunctionCalls(cleaned, 'log', (arg) => '(ln($arg)/2.302585092994046)');

    // Basic replacements
    cleaned = cleaned
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', math.pi.toString())
        .replaceAll('e', math.e.toString());

    if (cleaned.contains('%')) {
      cleaned = cleaned.replaceAll('%', '/100');
    }

    return cleaned;
  }

  String _transformFunctionCalls(String expr, String funcName, String Function(String arg) replacer) {
    String pattern = '$funcName(';
    while (expr.contains(pattern)) {
      int idx = expr.indexOf(pattern);
      int startArg = idx + pattern.length;
      int depth = 1;
      int cur = startArg;
      while (cur < expr.length && depth > 0) {
        if (expr[cur] == '(') depth++;
        if (expr[cur] == ')') depth--;
        if (depth > 0) cur++;
      }
      if (depth > 0) {
        String arg = expr.substring(startArg);
        String replacement = replacer(arg);
        expr = expr.substring(0, idx) + replacement;
        break;
      } else {
        String arg = expr.substring(startArg, cur);
        String replacement = replacer(arg);
        expr = expr.substring(0, idx) + replacement + expr.substring(cur + 1);
      }
    }
    return expr;
  }

  String _replaceFactorials(String expr) {
    while (expr.contains('!')) {
      int bangIndex = expr.indexOf('!');
      if (bangIndex == 0) {
        expr = expr.replaceFirst('!', '');
        continue;
      }

      int start = bangIndex - 1;
      if (expr[start] == ')') {
        int depth = 1;
        start--;
        while (start >= 0 && depth > 0) {
          if (expr[start] == ')') depth++;
          if (expr[start] == '(') depth--;
          if (depth > 0) start--;
        }
        if (start < 0) return 'Error';

        String subExpr = expr.substring(start + 1, bangIndex - 1);
        double subVal = _evalRaw(subExpr);
        if (subVal.isNaN || subVal < 0 || subVal != subVal.toInt() || subVal > 170) {
          return 'Error';
        }
        double fact = _factorial(subVal.toInt());
        expr = expr.substring(0, start) + fact.toString() + expr.substring(bangIndex + 1);
      } else {
        while (start >= 0 && (RegExp(r'[0-9\.\πe]').hasMatch(expr[start]))) {
          start--;
        }
        start++;
        if (start >= bangIndex) return 'Error';

        String numStr = expr.substring(start, bangIndex);
        double subVal = _evalRaw(numStr);
        if (subVal.isNaN || subVal < 0 || subVal != subVal.toInt() || subVal > 170) {
          return 'Error';
        }
        double fact = _factorial(subVal.toInt());
        expr = expr.substring(0, start) + fact.toString() + expr.substring(bangIndex + 1);
      }
    }
    return expr;
  }

  double _factorial(int n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1.0;
    double res = 1.0;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }

  double _evalRaw(String rawExpr) {
    try {
      String prep = _prepareExpression(rawExpr);
      if (prep == 'Error') return double.nan;

      int openParen = '('.allMatches(prep).length;
      int closeParen = ')'.allMatches(prep).length;
      while (openParen > closeParen) {
        prep += ')';
        closeParen++;
      }

      Parser p = Parser();
      Expression exp = p.parse(prep);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (_) {
      return double.nan;
    }
  }

  void autoEvaluate() {
    if (expression.isEmpty) {
      result = '0';
      return;
    }

    try {
      String cleanExpression = expression;
      
      while (cleanExpression.isNotEmpty && ['÷', '×', '-', '+', '^', '(', '.'].any((op) => cleanExpression.endsWith(op))) {
        cleanExpression = cleanExpression.substring(0, cleanExpression.length - 1);
      }

      if (cleanExpression.isEmpty) {
        result = '0';
        return;
      }

      String prep = _prepareExpression(cleanExpression);
      if (prep == 'Error') return;

      int openParen = '('.allMatches(prep).length;
      int closeParen = ')'.allMatches(prep).length;
      while (openParen > closeParen) {
        prep += ')';
        closeParen++;
      }

      Parser p = Parser();
      Expression exp = p.parse(prep);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      if (!eval.isNaN && !eval.isInfinite) {
        result = _formatValue(eval);
      }
    } catch (_) {
      // Silently fail for real-time preview
    }
  }

  void evaluate() {
    try {
      String prep = _prepareExpression(expression);
      if (prep == 'Error') {
        result = 'Error';
        return;
      }

      int openParen = '('.allMatches(prep).length;
      int closeParen = ')'.allMatches(prep).length;
      while (openParen > closeParen) {
        prep += ')';
        closeParen++;
      }

      Parser p = Parser();
      Expression exp = p.parse(prep);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      if (eval.isNaN || eval.isInfinite) {
        result = 'Error';
      } else {
        result = _formatValue(eval);
      }
    } catch (_) {
      result = 'Error';
    }
  }

  String _formatValue(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    } else {
      String formatted = val.toStringAsFixed(8);
      while (formatted.contains('.') && (formatted.endsWith('0') || formatted.endsWith('.'))) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
      return formatted;
    }
  }

  static const String _historyKey = 'calculator_history_list';

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_historyKey);
      if (jsonList != null) {
        historyList = jsonList
            .map((item) => CalculationHistory.fromJson(json.decode(item)))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = historyList
          .map((item) => json.encode(item.toJson()))
          .toList();
      await prefs.setStringList(_historyKey, jsonList);
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    historyList.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (_) {}
  }
}
