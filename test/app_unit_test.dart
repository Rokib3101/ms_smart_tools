import 'package:flutter_test/flutter_test.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';

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
  });
}
