import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/app_more_menu.dart';

class MSImageDashboard extends StatelessWidget {
  const MSImageDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ImageToolItem(
        title: 'QR Scanner',
        subtitle: 'Scan QR & Barcodes',
        icon: Icons.qr_code_scanner,
        color: Colors.teal,
        route: '/qr-scanner',
      ),
      _ImageToolItem(
        title: 'QR Generator',
        subtitle: 'Create Custom QR Code',
        icon: Icons.qr_code,
        color: Colors.indigo,
        route: '/qr-generator',
      ),
      _ImageToolItem(
        title: 'Image Merge',
        subtitle: 'Combine Multiple Images',
        icon: Icons.call_merge,
        color: Colors.blue,
        route: '/image-merge',
      ),
      _ImageToolItem(
        title: 'Image Overlay',
        subtitle: 'Add Layers & Watermarks',
        icon: Icons.layers,
        color: Colors.green,
        route: '/image-overlay',
      ),
      _ImageToolItem(
        title: 'Document Scanner',
        subtitle: 'Scan & Crop Documents',
        icon: Icons.document_scanner,
        color: Colors.deepPurple,
        route: '/doc-scanner',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MS Image',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          AppMoreMenuButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => context.push(tool.route),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tool.icon, color: tool.color, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        tool.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImageToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _ImageToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
