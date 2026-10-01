import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class FinanceHomeScreen extends StatelessWidget {
  const FinanceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MS Finance', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 'about':
                  context.push('/about');
                  break;
                case 'social_media':
                  context.push('/social-media');
                  break;
                case 'privacy_policy':
                  context.push('/privacy-policy');
                  break;
                case 'settings':
                  context.push('/settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 12),
                    Text('About'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'social_media',
                child: Row(
                  children: [
                    Icon(Icons.public, size: 20),
                    SizedBox(width: 12),
                    Text('Social Media'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'privacy_policy',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Privacy Policy'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildToolCard(
                  context,
                  title: 'Personal Finance',
                  subtitle: 'Budget & Expenses',
                  icon: Icons.account_balance_wallet,
                  color: Colors.indigo,
                  onTap: () => context.push('/finance'),
                ),
                _buildToolCard(
                  context,
                  title: 'Cash Counter',
                  subtitle: 'Notes & Coins',
                  icon: Icons.money,
                  color: Colors.green,
                  onTap: () => context.push('/cash-counter'),
                ),
                _buildToolCard(
                  context,
                  title: 'Price Comparator',
                  subtitle: 'Compare Unit Prices',
                  icon: Icons.price_check,
                  color: Colors.purple,
                  onTap: () => context.push('/comparator'),
                ),
                _buildToolCard(
                  context,
                  title: 'Shopping List',
                  subtitle: 'Checklists & Markets',
                  icon: Icons.shopping_cart,
                  color: Colors.blueAccent,
                  onTap: () => context.push('/shopping'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
