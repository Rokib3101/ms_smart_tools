import 'package:math_expressions/math_expressions.dart';
import 'core_utils.dart';

class MathEvaluator {
  static double? evaluate(String input, {double? baseValue}) {
    String clean = input.trim();
    if (clean.isEmpty) return 0.0;

    clean = BanglaUtils.toEnglish(clean);
    clean = clean
        .replaceAll(',', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('–', '-');

    if (baseValue != null) {
      final noSpaces = clean.replaceAll(' ', '');
      if (noSpaces.startsWith('+') || noSpaces.startsWith('-')) {
        clean = '${formatNumber(baseValue)}$noSpaces';
      }
    }

    try {
      final simpleVal = double.tryParse(clean);
      if (simpleVal != null) {
        return simpleVal;
      }

      Parser p = Parser();
      Expression exp = p.parse(clean);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  static bool isExpression(String input) {
    final clean = BanglaUtils.toEnglish(input.trim());
    return clean.contains('+') ||
        clean.contains('-') ||
        clean.contains('*') ||
        clean.contains('/') ||
        clean.contains('×') ||
        clean.contains('÷');
  }

  static String formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      String str = value.toStringAsFixed(2);
      if (str.endsWith('.00')) {
        return str.substring(0, str.length - 3);
      }
      if (str.endsWith('0')) {
        return str.substring(0, str.length - 1);
      }
      return str;
    }
  }
}
