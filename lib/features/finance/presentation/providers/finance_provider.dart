import 'package:flutter/material.dart';
import '../../data/models/finance_models.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/repositories/hive_finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _repository;

  FinanceProvider({FinanceRepository? repository})
      : _repository = repository ?? HiveFinanceRepository() {
    _init();
  }

  Future<void> _init() async {
    await _repository.initDefaultWallets();
    await _repository.initDefaultCategories();
    notifyListeners();
  }

  List<Transaction> get transactions => _repository.getTransactions();
  List<Transaction> get trashedTransactions => _repository.getTrashedTransactions();
  List<Wallet> get wallets => _repository.getWallets();
  List<Category> get categories => _repository.getCategories();

  double get totalBalance => wallets.fold(0, (sum, w) => sum + w.balance);

  // Category Management
  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    notifyListeners();
  }

  List<Category> getCategoriesByType(TransactionType type) {
    return categories.where((c) => c.type == type).toList();
  }

  // Wallet Management
  Future<void> addWallet(Wallet wallet) async {
    await _repository.addWallet(wallet);
    notifyListeners();
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _repository.updateWallet(wallet);
    notifyListeners();
  }

  Future<void> deleteWallet(String walletId) async {
    await _repository.deleteWallet(walletId);
    notifyListeners();
  }

  // Transaction Management
  Future<void> addTransaction(Transaction tx) async {
    await _repository.addTransaction(tx);
    notifyListeners();
  }

  // Soft Delete (Move to Trash)
  Future<void> deleteTransaction(Transaction tx) async {
    await _repository.deleteTransaction(tx);
    notifyListeners();
  }

  // Restore from Trash
  Future<void> restoreTransaction(Transaction tx) async {
    await _repository.restoreTransaction(tx);
    notifyListeners();
  }

  // Permanent Delete
  Future<void> permanentDeleteTransaction(Transaction tx) async {
    await _repository.permanentDeleteTransaction(tx);
    notifyListeners();
  }

  // Empty Trash
  Future<void> emptyTrash() async {
    await _repository.emptyTrash();
    notifyListeners();
  }

  Future<void> clearAllTransactions() async {
    await _repository.clearAllTransactions();
    notifyListeners();
  }

  void reloadData() {
    notifyListeners();
  }

  // Analytics
  double getMonthlyTotal(TransactionType type, int month, int year) {
    return transactions
        .where((tx) => tx.type == type && tx.date.month == month && tx.date.year == year)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  Map<int, Map<String, double>> getYearlyMonthlySummaries(int year) {
    final summaries = <int, Map<String, double>>{};
    for (int m = 1; m <= 12; m++) {
      double income = getMonthlyTotal(TransactionType.income, m, year);
      double expense = getMonthlyTotal(TransactionType.expense, m, year);
      if (income > 0 || expense > 0) {
        summaries[m] = {
          'income': income,
          'expense': expense,
          'balance': income - expense,
        };
      }
    }
    return summaries;
  }

  Map<String, double> getCategoryData(TransactionType type) {
    final data = <String, double>{};
    for (var tx in transactions.where((t) => t.type == type)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }
    return data;
  }
}
