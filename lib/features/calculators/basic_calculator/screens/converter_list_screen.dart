import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/registry/tool_registry.dart';
import '../../../../core/registry/tool_provider.dart';

class ConverterListScreen extends StatelessWidget {
  const ConverterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final triangleTools = ToolRegistry.triangleTools;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Converters & Calculators',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: triangleTools.length,
        itemBuilder: (context, index) {
          final tool = triangleTools[index];
          return Card(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: InkWell(
              onTap: () async {
                try {
                  Provider.of<ToolProvider>(context, listen: false).addToRecent(tool.id);
                } catch (_) {}
                await context.push(tool.route);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tool.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(tool.icon, color: tool.color, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tool.titleBn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
