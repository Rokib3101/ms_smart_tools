import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/finance_provider.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';

class SmartInsightsScreen extends StatelessWidget {
  const SmartInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    final now = DateTime.now();
    final monthlyIncome = financeProvider.getMonthlyTotal(TransactionType.income, now.month, now.year);
    final monthlyExpense = financeProvider.getMonthlyTotal(TransactionType.expense, now.month, now.year);
    final savings = monthlyIncome - monthlyExpense;
    final savingsRate = monthlyIncome > 0 ? (savings / monthlyIncome) * 100 : 0.0;

    final categoryData = financeProvider.getCategoryData(TransactionType.expense);
    var sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: 'Monthly Financial Health',
              color: Colors.blue[800]!,
              child: Column(
                children: [
                  _rowItem('Total Income:', '৳${monthlyIncome.toStringAsFixed(0)}', Colors.greenAccent),
                  _rowItem('Total Expense:', '৳${monthlyExpense.toStringAsFixed(0)}', Colors.redAccent),
                  const Divider(color: Colors.white24),
                  _rowItem('Savings:', '৳${savings.toStringAsFixed(0)}', savings >= 0 ? Colors.greenAccent : Colors.orangeAccent),
                  _rowItem('Savings Rate:', '${savingsRate.toStringAsFixed(1)}%', Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category-wise Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (sortedCategories.isEmpty)
              const Center(child: Text('No expense data found.', style: TextStyle(color: Colors.grey)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final entry = sortedCategories[index];
                  final percentage = monthlyExpense > 0 ? (entry.value / monthlyExpense) * 100 : 0.0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        color: Colors.redAccent,
                      ),
                      trailing: Text(
                        '৳${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(value, style: TextStyle(color: valColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
