import 'package:flutter_test/flutter_test.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';
import 'package:ms_smart_tools/features/converter/land/land_logic.dart';

void main() {
  group('Core Unit Tests - MS Smart Tools', () {
    test('Transaction Model creation test', () {
      final tx = Transaction.create(
        amount: 1500.0,
        category: 'Salary',
        type: TransactionType.income,
        walletId: 'bank',
        note: 'Monthly salary',
      );

      expect(tx.amount, 1500.0);
      expect(tx.category, 'Salary');
      expect(tx.type, TransactionType.income);
      expect(tx.walletId, 'bank');
      expect(tx.note, 'Monthly salary');
    });

    test('Wallet balance computation test', () {
      var wallet = Wallet(id: 'bank', name: 'Bank Account', balance: 5000.0, icon: 'account_balance');

      // Add income
      wallet = wallet.copyWith(balance: wallet.balance + 2000.0);
      expect(wallet.balance, 7000.0);

      // Subtract expense
      wallet = wallet.copyWith(balance: wallet.balance - 1500.0);
      expect(wallet.balance, 5500.0);
    });

    test('BMI calculation logic test', () {
      double weightKg = 75.0;
      double heightM = 1.75;
      double bmi = weightKg / (heightM * heightM);

      expect(bmi.toStringAsFixed(1), '24.5');
    });

    test('LandLogic conversion and unit order test', () {
      final results = LandLogic.convert(1.0, 'acre');
      expect(results.containsKey('sq_mi'), true);
      expect(results.containsKey('sq_km'), true);
      expect(results.containsKey('sq_yd'), true);
      expect(results.containsKey('sq_in'), true);
      expect(results.containsKey('sq_cm'), true);
      expect(results.containsKey('sq_mm'), true);

      // Verify keys order (largest to smallest)
      final keys = results.keys.toList();
      expect(keys[0], 'sq_mi');
      expect(keys[1], 'sq_km');
      expect(keys[2], 'hectare');
      expect(keys[3], 'acre');
      expect(keys[4], 'bigha');
      expect(keys[5], 'are');
      expect(keys[6], 'katha');
      expect(keys[7], 'decimal');
      expect(keys[8], 'sqm');
      expect(keys[9], 'sq_yd');
      expect(keys[10], 'sqft');
      expect(keys[11], 'sq_in');
      expect(keys[12], 'sq_cm');
      expect(keys[13], 'sq_mm');
    });
  });
}
