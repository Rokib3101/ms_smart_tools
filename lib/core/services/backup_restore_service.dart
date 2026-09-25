import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';
import 'package:ms_smart_tools/core/utils/storage_utils.dart';

class BackupSummary {
  final int transactionCount;
  final int trashedCount;
  final int walletCount;
  final int categoryCount;
  final DateTime? latestTransactionDate;
  final DateTime? backupDate;
  final int version;

  BackupSummary({
    required this.transactionCount,
    required this.trashedCount,
    required this.walletCount,
    required this.categoryCount,
    this.latestTransactionDate,
    this.backupDate,
    this.version = 1,
  });
}

class BackupRestoreService {
  // Export Finance Data to JSON (Version 2 with Soft Delete support)
  static Future<String?> exportToJson() async {
    try {
      final txBox = Hive.box<Transaction>('transactions');
      final walletBox = Hive.box<Wallet>('wallets');
      final catBox = Hive.box<Category>('categories');

      final data = {
        'version': 2,
        'backupDate': DateTime.now().toIso8601String(),
        'transactions': txBox.values.map((t) => {
          'id': t.id,
          'amount': t.amount,
          'category': t.category,
          'date': t.date.toIso8601String(),
          'note': t.note,
          'type': t.type.index,
          'walletId': t.walletId,
          'toWalletId': t.toWalletId,
          'isDeleted': t.isDeleted,
          'deletedAt': t.deletedAt?.toIso8601String(),
        }).toList(),
        'wallets': walletBox.values.map((w) => {
          'id': w.id,
          'name': w.name,
          'balance': w.balance,
          'icon': w.icon,
        }).toList(),
        'categories': catBox.values.map((c) => {
          'id': c.id,
          'name': c.name,
          'type': c.type.index,
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${dir.path}/ms_smart_tools_backup_$dateStr.json';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      await StorageUtils.saveFileToCustomFolder(filePath, 'ms_smart_tools_backup_$dateStr.json');
      return filePath;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  // Export Transactions to CSV
  static Future<String?> exportToCsv() async {
    try {
      final txBox = Hive.box<Transaction>('transactions');
      final buffer = StringBuffer();
      buffer.writeln('ID,Amount,Type,Category,Date,WalletID,Note,IsDeleted');

      for (var t in txBox.values.where((t) => !t.isDeleted)) {
        buffer.writeln('"${t.id}",${t.amount},"${t.type.name}","${t.category}","${t.date.toIso8601String()}","${t.walletId}","${t.note.replaceAll('"', '""')}","${t.isDeleted}"');
      }

      final dir = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${dir.path}/ms_smart_tools_transactions_$dateStr.csv';

      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      await StorageUtils.saveFileToCustomFolder(filePath, 'ms_smart_tools_transactions_$dateStr.csv');
      return filePath;
    } catch (e) {
      print('CSV Export error: $e');
      return null;
    }
  }

  // Parse backup file and return summary for pre-restore confirmation (Schema Version Aware)
  static Future<BackupSummary?> analyzeBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (!data.containsKey('transactions') && !data.containsKey('wallets')) {
        return null;
      }

      final version = (data['version'] as int?) ?? 1;
      final txs = data['transactions'] as List? ?? [];
      final wallets = data['wallets'] as List? ?? [];
      final categories = data['categories'] as List? ?? [];
      final backupDateStr = data['backupDate'] as String?;
      final backupDate = backupDateStr != null ? DateTime.tryParse(backupDateStr) : null;

      int activeCount = 0;
      int trashedCount = 0;
      DateTime? latestDate;

      for (var t in txs) {
        if (t is Map) {
          final isDel = t['isDeleted'] == true;
          if (isDel) {
            trashedCount++;
          } else {
            activeCount++;
          }

          if (t['date'] != null) {
            final date = DateTime.tryParse(t['date'].toString());
            if (date != null) {
              if (latestDate == null || date.isAfter(latestDate)) {
                latestDate = date;
              }
            }
          }
        }
      }

      return BackupSummary(
        transactionCount: activeCount,
        trashedCount: trashedCount,
        walletCount: wallets.length,
        categoryCount: categories.length,
        latestTransactionDate: latestDate,
        backupDate: backupDate,
        version: version,
      );
    } catch (e) {
      print('Analyze backup error: $e');
      return null;
    }
  }

  // Restore backup from JSON file (Supports Schema Migration / Versioning)
  static Future<bool> restoreFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final version = (data['version'] as int?) ?? 1;

      final txBox = Hive.box<Transaction>('transactions');
      final walletBox = Hive.box<Wallet>('wallets');
      final catBox = Hive.box<Category>('categories');

      await txBox.clear();
      await walletBox.clear();
      await catBox.clear();

      final txs = data['transactions'] as List? ?? [];
      for (var t in txs) {
        if (t is Map) {
          // Schema Migration handling based on version
          bool isDeleted = false;
          DateTime? deletedAt;

          if (version >= 2) {
            isDeleted = t['isDeleted'] == true;
            if (t['deletedAt'] != null) {
              deletedAt = DateTime.tryParse(t['deletedAt'].toString());
            }
          } else {
            // Version 1 fallback/migration: default values
            isDeleted = false;
            deletedAt = null;
          }

          final tx = Transaction(
            id: t['id']?.toString() ?? '',
            amount: (t['amount'] as num?)?.toDouble() ?? 0.0,
            category: t['category']?.toString() ?? '',
            date: DateTime.tryParse(t['date']?.toString() ?? '') ?? DateTime.now(),
            note: t['note']?.toString() ?? '',
            type: TransactionType.values[(t['type'] as int?) ?? 0],
            walletId: t['walletId']?.toString() ?? '',
            toWalletId: t['toWalletId']?.toString(),
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          );
          await txBox.put(tx.id, tx);
        }
      }

      final wallets = data['wallets'] as List? ?? [];
      for (var w in wallets) {
        if (w is Map) {
          final wallet = Wallet(
            id: w['id']?.toString() ?? '',
            name: w['name']?.toString() ?? '',
            balance: (w['balance'] as num?)?.toDouble() ?? 0.0,
            icon: w['icon']?.toString() ?? 'account_balance_wallet',
          );
          await walletBox.put(wallet.id, wallet);
        }
      }

      final categories = data['categories'] as List? ?? [];
      for (var c in categories) {
        if (c is Map) {
          final category = Category(
            id: c['id']?.toString() ?? '',
            name: c['name']?.toString() ?? '',
            type: TransactionType.values[(c['type'] as int?) ?? 0],
          );
          await catBox.put(category.id, category);
        }
      }

      return true;
    } catch (e) {
      print('Restore error: $e');
      return false;
    }
  }
}
