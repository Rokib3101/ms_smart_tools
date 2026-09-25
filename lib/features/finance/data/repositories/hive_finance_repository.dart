import 'package:hive/hive.dart';
import '../../domain/repositories/finance_repository.dart';
import '../models/finance_models.dart';

class HiveFinanceRepository implements FinanceRepository {
  Box<Transaction> get _transactionBox => Hive.box<Transaction>('transactions');
  Box<Wallet> get _walletBox => Hive.box<Wallet>('wallets');
  Box<Category> get _categoryBox => Hive.box<Category>('categories');

  @override
  List<Transaction> getTransactions() {
    return _transactionBox.values
        .where((tx) => !tx.isDeleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<Transaction> getTrashedTransactions() {
    return _transactionBox.values
        .where((tx) => tx.isDeleted)
        .toList()
      ..sort((a, b) => (b.deletedAt ?? b.date).compareTo(a.deletedAt ?? a.date));
  }

  @override
  List<Wallet> getWallets() {
    return _walletBox.values.toList();
  }

  @override
  List<Category> getCategories() {
    return _categoryBox.values.toList();
  }

  @override
  Future<void> initDefaultWallets() async {
    if (_walletBox.isEmpty) {
      final defaultWallets = [
        Wallet(id: 'bank', name: 'Bank', balance: 0, icon: 'account_balance'),
        Wallet(id: 'cash', name: 'Cash', balance: 0, icon: 'money'),
      ];
      for (var w in defaultWallets) {
        await _walletBox.put(w.id, w);
      }
    }
  }

  @override
  Future<void> initDefaultCategories() async {
    if (_categoryBox.isEmpty) {
      final defaultCategories = [
        Category(id: 'inc_01_salary', name: 'Salary', type: TransactionType.income),
        Category(id: 'inc_02_business', name: 'Business', type: TransactionType.income),
        Category(id: 'exp_01_food', name: 'Food', type: TransactionType.expense),
        Category(id: 'exp_02_medicine', name: 'Medicine', type: TransactionType.expense),
        Category(id: 'exp_03_transport', name: 'Transport', type: TransactionType.expense),
        Category(id: 'exp_04_utilities', name: 'Utilities', type: TransactionType.expense),
        Category(id: 'exp_05_others', name: 'Others', type: TransactionType.expense),
      ];
      for (var c in defaultCategories) {
        await _categoryBox.put(c.id, c);
      }
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categoryBox.delete(categoryId);
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    await _walletBox.put(wallet.id, wallet);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    await _walletBox.put(wallet.id, wallet);
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await _walletBox.delete(walletId);
  }

  @override
  Future<void> addTransaction(Transaction tx) async {
    await _transactionBox.put(tx.id, tx);

    if (tx.type == TransactionType.transfer && tx.toWalletId != null) {
      final fromWallet = _walletBox.get(tx.walletId);
      final toWallet = _walletBox.get(tx.toWalletId!);
      if (fromWallet != null && toWallet != null) {
        await _walletBox.put(tx.walletId, fromWallet.copyWith(balance: fromWallet.balance - tx.amount));
        await _walletBox.put(tx.toWalletId!, toWallet.copyWith(balance: toWallet.balance + tx.amount));
      }
    } else {
      final wallet = _walletBox.get(tx.walletId);
      if (wallet != null) {
        if (tx.type == TransactionType.income) {
          await _walletBox.put(tx.walletId, wallet.copyWith(balance: wallet.balance + tx.amount));
        } else if (tx.type == TransactionType.expense) {
          await _walletBox.put(tx.walletId, wallet.copyWith(balance: wallet.balance - tx.amount));
        }
      }
    }
  }

  @override
  Future<void> deleteTransaction(Transaction tx) async {
    if (tx.isDeleted) return;

    if (tx.type == TransactionType.transfer && tx.toWalletId != null) {
      final fromWallet = _walletBox.get(tx.walletId);
      final toWallet = _walletBox.get(tx.toWalletId!);
      if (fromWallet != null && toWallet != null) {
        await _walletBox.put(tx.walletId, fromWallet.copyWith(balance: fromWallet.balance + tx.amount));
        await _walletBox.put(tx.toWalletId!, toWallet.copyWith(balance: toWallet.balance - tx.amount));
      }
    } else {
      final wallet = _walletBox.get(tx.walletId);
      if (wallet != null) {
        if (tx.type == TransactionType.income) {
          await _walletBox.put(tx.walletId, wallet.copyWith(balance: wallet.balance - tx.amount));
        } else if (tx.type == TransactionType.expense) {
          await _walletBox.put(tx.walletId, wallet.copyWith(balance: wallet.balance + tx.amount));
        }
      }
    }

    final updated = tx.copyWith(isDeleted: true, deletedAt: DateTime.now());
    await _transactionBox.put(updated.id, updated);
  }

  @override
  Future<void> restoreTransaction(Transaction tx) async {
    if (!tx.isDeleted) return;

    if (tx.type == TransactionType.transfer && tx.toWalletId != null) {
      final fromWallet = _walletBox.get(tx.walletId);
      final toWallet = _walletBox.get(tx.toWalletId!);
      if (fromWallet != null && toWallet != null) {
        await _walletBox.put(tx.walletId, fromWallet.copyWith(balance: fromWallet.balance - tx.amount));
        await _walletBox.put(tx.toWalletId!, toWallet.copyWith(balance: toWallet.balance + tx.amount));
      }
    } else {
      final wallet = _walletBox.get(tx.walletId);
      if (wallet != null) {
        if (tx.type == TransactionType.income) {
          await _walletBox.put(tx.walletId, wallet.copyWith(balance: wallet.balance + tx.amount));
        } else if (tx.type == TransactionType.expense) {
          await _walletBox.put(tx.walletId, wallet.copyWith(balance: wallet.balance - tx.amount));
        }
      }
    }

    final updated = tx.copyWith(isDeleted: false, deletedAt: null);
    await _transactionBox.put(updated.id, updated);
  }

  @override
  Future<void> permanentDeleteTransaction(Transaction tx) async {
    if (tx.isInBox) {
      await tx.delete();
    } else {
      final key = _transactionBox.keys.firstWhere(
        (k) => _transactionBox.get(k)?.id == tx.id,
        orElse: () => null,
      );
      if (key != null) {
        await _transactionBox.delete(key);
      }
    }
  }

  @override
  Future<void> emptyTrash() async {
    final trashed = getTrashedTransactions();
    for (var tx in trashed) {
      await permanentDeleteTransaction(tx);
    }
  }

  @override
  Future<void> clearAllTransactions() async {
    await _transactionBox.clear();
    for (var w in _walletBox.values) {
      await _walletBox.put(w.id, w.copyWith(balance: 0));
    }
  }
}
