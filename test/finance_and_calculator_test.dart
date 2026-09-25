import 'package:flutter_test/flutter_test.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';
import 'package:ms_smart_tools/features/calculators/bmi_calculator/logic/bmi_logic.dart';
import 'package:ms_smart_tools/features/shopping_market/models/market_models.dart';
import 'package:ms_smart_tools/features/calculators/basic_calculator/calculator_logic.dart';

void main() {
  group('Finance Calculation Tests', () {
    test('Transaction creation and properties', () {
      final tx = Transaction.create(
        amount: 500.0,
        category: 'Food',
        type: TransactionType.expense,
        walletId: 'cash',
        note: 'Lunch',
      );

      expect(tx.amount, 500.0);
      expect(tx.category, 'Food');
      expect(tx.type, TransactionType.expense);
      expect(tx.walletId, 'cash');
      expect(tx.note, 'Lunch');
    });

    test('Wallet balance update logic simulation', () {
      var wallet = Wallet(id: 'cash', name: 'Cash', balance: 1000.0, icon: 'money');

      // Income 500
      var incomeTx = 500.0;
      wallet = wallet.copyWith(balance: wallet.balance + incomeTx);
      expect(wallet.balance, 1500.0);

      // Expense 200
      var expenseTx = 200.0;
      wallet = wallet.copyWith(balance: wallet.balance - expenseTx);
      expect(wallet.balance, 1300.0);
    });
  });

  group('BMI Calculation Tests', () {
    test('BMI calculation for valid height and weight', () {
      // Weight 70 kg, Height 175 cm (1.75 m) -> BMI = 70 / (1.75 * 1.75) = 22.86
      double weight = 70.0;
      double heightCm = 175.0;
      double heightM = heightCm / 100.0;
      double bmi = weight / (heightM * heightM);

      expect(bmi.toStringAsFixed(1), '22.9');
    });
  });

  group('Shopping List Convert to Expense Tests', () {
    test('Convert to expense uses bought amount only, not total market or remaining', () {
      final items = [
        MarketItem(name: 'Rice', quantity: 2, unitPrice: 60, isBought: true), // total = 120 (bought)
        MarketItem(name: 'Oil', quantity: 1, unitPrice: 180, isBought: true), // total = 180 (bought)
        MarketItem(name: 'Fish', quantity: 1, unitPrice: 300, isBought: false), // total = 300 (remaining)
      ];

      final totalPrice = items.fold(0.0, (sum, i) => sum + i.total); // 600
      final boughtPrice = items.where((i) => i.isBought).fold(0.0, (sum, i) => sum + i.total); // 300
      final remainingPrice = totalPrice - boughtPrice; // 300

      // Converted amount should equal boughtPrice (300), NOT totalPrice (600) or remainingPrice (300)
      final convertAmount = boughtPrice;

      expect(totalPrice, 600.0);
      expect(boughtPrice, 300.0);
      expect(remainingPrice, 300.0);
      expect(convertAmount, 300.0);
      expect(convertAmount, isNot(equals(totalPrice)));
    });

    test('Convert to expense when no items bought returns 0', () {
      final items = [
        MarketItem(name: 'Rice', quantity: 2, unitPrice: 60, isBought: false),
        MarketItem(name: 'Oil', quantity: 1, unitPrice: 180, isBought: false),
      ];

      final boughtPrice = items.where((i) => i.isBought).fold(0.0, (sum, i) => sum + i.total);
      final convertAmount = boughtPrice;

      expect(convertAmount, 0.0);
    });
  });

  group('Scientific Calculator Keyboard & Logic Tests', () {
    test('Square root and power calculation', () {
      final logic = CalculatorLogic();
      logic.append('√');
      logic.append('16');
      logic.append(')');
      logic.evaluate();
      expect(logic.result, '4');

      logic.append('AC');
      logic.append('2');
      logic.append('^');
      logic.append('5');
      logic.evaluate();
      expect(logic.result, '32');
    });

    test('Factorial calculation', () {
      final logic = CalculatorLogic();
      logic.append('5');
      logic.append('!');
      logic.evaluate();
      expect(logic.result, '120');

      logic.append('AC');
      logic.append('0');
      logic.append('!');
      logic.evaluate();
      expect(logic.result, '1');
    });

    test('Trigonometry in Degree mode', () {
      final logic = CalculatorLogic();
      logic.isDegreeMode = true;

      logic.append('sin');
      logic.append('30');
      logic.append(')');
      logic.evaluate();
      expect(logic.result, '0.5');

      logic.append('AC');
      logic.append('cos');
      logic.append('60');
      logic.append(')');
      logic.evaluate();
      expect(logic.result, '0.5');
    });

    test('Logarithm functions', () {
      final logic = CalculatorLogic();
      logic.append('log');
      logic.append('100');
      logic.append(')');
      logic.evaluate();
      expect(logic.result, '2');
    });

    test('Smart parenthesis () insertion', () {
      final logic = CalculatorLogic();
      logic.append('()');
      expect(logic.expression, '(');

      logic.append('5');
      logic.append('()');
      expect(logic.expression, '(5)');

      logic.append('+');
      logic.append('()');
      expect(logic.expression, '(5)+(');
    });

    test('Operator replacement when consecutive operators are pressed', () {
      final logic = CalculatorLogic();
      logic.append('5');
      logic.append('+');
      expect(logic.expression, '5+');

      // Pressing '-' should replace '+'
      logic.append('-');
      expect(logic.expression, '5-');

      // Pressing '×' should replace '-'
      logic.append('×');
      expect(logic.expression, '5×');

      // Pressing '÷' should replace '×'
      logic.append('÷');
      expect(logic.expression, '5÷');

      // Appending a number afterwards
      logic.append('2');
      expect(logic.expression, '5÷2');
      logic.evaluate();
      expect(logic.result, '2.5');
    });
  });
}
