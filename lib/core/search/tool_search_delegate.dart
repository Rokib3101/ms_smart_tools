import 'package:flutter/material.dart';
import '../registry/tool_registry.dart';
import '../registry/smart_tool_model.dart';

class ToolSearchDelegate extends SearchDelegate<SmartTool?> {
  @override
  String get searchFieldLabel => 'Search tools...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = ToolRegistry.search(query);
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = ToolRegistry.search(query);
    return _buildList(results);
  }

  Widget _buildList(List<SmartTool> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No tools found!'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tool = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: tool.color.withValues(alpha: 0.1),
            child: Icon(tool.icon, color: tool.color),
          ),
          title: Text(tool.titleEn),
          onTap: () => close(context, tool),
        );
      },
    );
  }
}
