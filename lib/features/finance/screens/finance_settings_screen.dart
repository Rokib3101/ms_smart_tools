import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/finance_provider.dart';
import 'package:ms_smart_tools/core/security/app_lock_service.dart';
import 'package:ms_smart_tools/core/security/app_lock_screen.dart';
import 'package:ms_smart_tools/core/services/backup_restore_service.dart';
import 'package:ms_smart_tools/core/utils/storage_utils.dart';
import 'package:ms_smart_tools/core/navigation/app_router.dart';

class FinanceSettingsScreen extends StatefulWidget {
  const FinanceSettingsScreen({super.key});

  @override
  State<FinanceSettingsScreen> createState() => _FinanceSettingsScreenState();
}

class _FinanceSettingsScreenState extends State<FinanceSettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Security & Privacy'),
              Consumer<AppLockService>(
                builder: (context, lockService, _) {
                  return Column(
                    children: [
                      SwitchListTile(
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                        ),
                        title: const Text('App Lock (PIN)', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Require 4-digit PIN to open Personal Finance'),
                        value: lockService.isPinSet,
                        onChanged: (bool value) async {
                          if (value) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppLockScreen(mode: AppLockMode.setPin),
                              ),
                            );
                          } else {
                            final verified = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppLockScreen(mode: AppLockMode.verifyToDisable),
                              ),
                            );
                            if (verified == true) {
                              await lockService.removePin();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('অ্যাপ লক বন্ধ করা হয়েছে')),
                                );
                              }
                            }
                          }
                        },
                      ),
                      if (lockService.isPinSet) ...[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.password, color: Theme.of(context).primaryColor),
                          ),
                          title: const Text('Change PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Update your 4-digit security PIN'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final verified = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppLockScreen(mode: AppLockMode.verifyToDisable),
                              ),
                            );
                            if (verified == true && context.mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AppLockScreen(mode: AppLockMode.setPin),
                                ),
                              );
                            }
                          },
                        ),
                        FutureBuilder<bool>(
                          future: lockService.isBiometricSupported(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return SwitchListTile(
                                secondary: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  child: Icon(Icons.fingerprint, color: Theme.of(context).primaryColor),
                                ),
                                title: const Text('Biometric Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Use Fingerprint or Face ID to unlock'),
                                value: lockService.biometricEnabled,
                                onChanged: (bool value) async {
                                  await lockService.setBiometricEnabled(value);
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const Divider(height: 32),
              _buildSectionTitle('Backup, Export & Restore'),
              _buildSettingsItem(
                context,
                'JSON Backup (লোকাল ব্যাকআপ)',
                'আপনার সকল অর্থায়নের ডাটা JSON ব্যাকআপ ফাইল হিসেবে সেভ ও শেয়ার করুন।',
                Icons.backup_outlined,
                onTap: () => _handleJsonBackup(context),
              ),
              const Divider(),
              _buildSettingsItem(
                context,
                'Export to CSV (এক্সপোর্ট সিএসভি)',
                'এক্সেল বা স্প্রেডশিটে দেখার জন্য লেনদেনের তালিকা CSV ফাইলে রূপান্তর করুন।',
                Icons.ios_share_outlined,
                onTap: () => _handleCsvExport(context),
              ),
              const Divider(),
              _buildSettingsItem(
                context,
                'Restore Data (ডাটা রিস্টোর)',
                'পূর্বে সংরক্ষিত JSON ব্যাকআপ ফাইল থেকে ডাটা ফিরিয়ে আনুন।',
                Icons.restore_outlined,
                iconColor: Colors.deepOrange,
                onTap: () => _handleRestore(context, provider),
              ),
              const Divider(height: 32),
              _buildSectionTitle('Finance Data Management'),
              _buildSettingsItem(
                context,
                'Wallet Management',
                'Manage your bank, MFS, or cash wallets.',
                Icons.account_balance_wallet,
                onTap: () => context.push(AppRoutes.financeWallets),
              ),
              const Divider(),
              _buildSettingsItem(
                context,
                'Category Management',
                'Add or remove income and expense categories.',
                Icons.category,
                onTap: () => context.push(AppRoutes.financeCategories),
              ),
              const Divider(),
              _buildSettingsItem(
                context,
                'Trash / Deleted Transactions',
                'View deleted transactions, restore them or permanently delete.',
                Icons.delete_outline,
                onTap: () => context.push(AppRoutes.financeTrash),
              ),
              const Divider(),
              _buildSettingsItem(
                context,
                'Clear Transaction Data',
                'Delete all transaction data and reset balances.',
                Icons.delete_forever,
                iconColor: Colors.red,
                onTap: () => _showClearDataConfirmation(context, provider),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    {required VoidCallback onTap, Color? iconColor}
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _handleJsonBackup(BuildContext context) {
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    _showExportOptionsSheet(
      context: context,
      title: 'JSON ব্যাকআপ (লোকাল ব্যাকআপ)',
      defaultFileName: 'ms_smart_tools_backup_$dateStr.json',
      exportAction: BackupRestoreService.exportToJson,
      shareTitle: 'MS Smart Tools Finance JSON Backup',
    );
  }

  void _handleCsvExport(BuildContext context) {
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    _showExportOptionsSheet(
      context: context,
      title: 'Export to CSV (এক্সপোর্ট সিএসভি)',
      defaultFileName: 'ms_smart_tools_transactions_$dateStr.csv',
      exportAction: BackupRestoreService.exportToCsv,
      shareTitle: 'MS Smart Tools Transactions CSV',
    );
  }

  void _showExportOptionsSheet({
    required BuildContext context,
    required String title,
    required String defaultFileName,
    required Future<String?> Function() exportAction,
    required String shareTitle,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    title.contains('CSV') ? Icons.table_chart_outlined : Icons.backup_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ফাইলটি সেভ বা শেয়ার করার মাধ্যম নির্বাচন করুন:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                child: Icon(Icons.sd_storage_outlined),
              ),
              title: const Text('স্টোরেজে সেভ করুন (Save to Storage)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('ডিভাইসের ফোন মেমোরি বা পছন্দসই ফোল্ডারে সেভ করুন'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _performSaveToStorage(context, exportAction, defaultFileName);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                foregroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.share_outlined),
              ),
              title: const Text('শেয়ার করুন (Share File)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('গুগল ড্রাইভ, ইমেইল বা হোয়াটসঅ্যাপে পাঠাতে শেয়ার করুন'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _performShare(context, exportAction, shareTitle);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _performSaveToStorage(
    BuildContext context,
    Future<String?> Function() exportAction,
    String defaultFileName,
  ) async {
    setState(() => _isLoading = true);
    final tempFilePath = await exportAction();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (tempFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ফাইল তৈরিতে সমস্যা হয়েছে')),
      );
      return;
    }

    final savedPath = await StorageUtils.saveDocumentToStorage(
      sourcePath: tempFilePath,
      fileName: defaultFileName,
    );

    if (!context.mounted) return;

    if (savedPath != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('সফলভাবে সেভ হয়েছে', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ফাইলটি ডিভাইসের স্টোরেজে সফলভাবে সেভ করা হয়েছে:'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  savedPath,
                  style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ঠিক আছে'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                Share.shareXFiles([XFile(tempFilePath)]);
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('শেয়ার করুন'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('স্টোরেজে সেভ করা হয়নি')),
      );
    }
  }

  Future<void> _performShare(
    BuildContext context,
    Future<String?> Function() exportAction,
    String shareTitle,
  ) async {
    setState(() => _isLoading = true);
    final filePath = await exportAction();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (filePath != null) {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: shareTitle,
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ফাইল তৈরিতে সমস্যা হয়েছে')),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, FinanceProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      return;
    }

    final filePath = result.files.single.path!;

    setState(() => _isLoading = true);
    final summary = await BackupRestoreService.analyzeBackupFile(filePath);
    setState(() => _isLoading = false);

    if (summary == null) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ত্রুটি'),
            content: const Text('বাছাইকৃত ফাইলটি সঠিক বা সমর্থিত JSON ব্যাকআপ ফাইল নয়।'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ঠিক আছে'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      _showPreRestoreConfirmationDialog(context, filePath, summary, provider);
    }
  }

  void _showPreRestoreConfirmationDialog(
    BuildContext context,
    String filePath,
    BackupSummary summary,
    FinanceProvider provider,
  ) {
    final backupDateStr = summary.backupDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(summary.backupDate!)
        : 'অজানা (Unknown)';

    final latestDataDateStr = summary.latestTransactionDate != null
        ? DateFormat('dd MMM yyyy').format(summary.latestTransactionDate!)
        : 'কোন ট্রানজেকশন নেই';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore_page_outlined, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('ব্যাকআপ রিস্টোর তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'রিস্টোর করার আগে ব্যাকআপ ফাইলের বিবরণ যাচাই করুন:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(Icons.calendar_today, 'ব্যাকআপের তারিখ:', backupDateStr),
                  const Divider(height: 16),
                  _buildSummaryRow(Icons.account_balance_wallet, 'ওয়ালেট/অ্যাকাউন্ট:', '${summary.walletCount} টি'),
                  const Divider(height: 16),
                  _buildSummaryRow(Icons.receipt_long, 'মোট ট্রানজেকশন:', '${summary.transactionCount} টি'),
                  const Divider(height: 16),
                  _buildSummaryRow(Icons.history, 'সর্বশেষ ডাটা পরিধি:', latestDataDateStr),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'সতর্কতা: রিস্টোর করলে বর্তমান সমস্ত ডাটা মুছে এই ফাইলের ডাটা বসবে।',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              final success = await BackupRestoreService.restoreFromJson(filePath);
              if (success) {
                provider.reloadData();
              }
              setState(() => _isLoading = false);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'ডাটা সফলভাবে রিস্টোর করা হয়েছে!'
                          : 'রিস্টোর করতে সমস্যা হয়েছে!',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('রিস্টোর নিশ্চিত করুন'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
        ),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showClearDataConfirmation(BuildContext context, FinanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Are you sure you want to clear all transaction data? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.clearAllTransactions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been cleared')),
              );
            },
            child: const Text('Yes, Clear All'),
          ),
        ],
      ),
    );
  }
}
