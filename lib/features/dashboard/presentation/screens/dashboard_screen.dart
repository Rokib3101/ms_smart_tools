import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../../../core/registry/tool_registry.dart';
import '../../../../core/registry/smart_tool_model.dart';
import '../../../../core/registry/tool_provider.dart';
import '../../../../core/security/app_lock_service.dart';
import '../../../../core/navigation/app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    // For sharing images while app is in memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        _navigateToSharedImage(value.first.path);
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing images while app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _navigateToSharedImage(value.first.path);
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  void _navigateToSharedImage(String path) {
    debugPrint("Shared image path received: $path");
    if (mounted) {
      context.push(AppRoutes.docScanner, extra: path);
    }
  }

  void _openTool(SmartTool tool) async {
    Provider.of<ToolProvider>(context, listen: false).addToRecent(tool.id);
    await context.push(tool.route);
    if (tool.id == 'finance' && mounted) {
      Provider.of<AppLockService>(context, listen: false).lockApp();
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'about':
        context.push(AppRoutes.about);
        break;
      case 'social_media':
        context.push(AppRoutes.socialMedia);
        break;
      case 'share_app':
        Share.share(
          'Check out MS Smart Tools app on GitHub: https://github.com/Rokib3101/ms_smart_tools',
        );
        break;
      case 'privacy_policy':
        context.push(AppRoutes.privacyPolicy);
        break;
      case 'settings':
        context.push(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MS Smart Tools',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
            onSelected: _handleMenuSelection,
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
                value: 'share_app',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Share App'),
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
      body: Consumer<ToolProvider>(
        builder: (context, toolProvider, child) {
          final allTools = ToolRegistry.allTools;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: allTools.length,
                  itemBuilder: (context, index) {
                    return _buildToolCard(allTools[index], toolProvider);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolCard(SmartTool tool, ToolProvider toolProvider) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        onTap: () => _openTool(tool),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity), // To ensure center alignment
              Icon(tool.icon, color: tool.color, size: 32),
              const SizedBox(height: 8),
              Text(
                tool.titleBn,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
