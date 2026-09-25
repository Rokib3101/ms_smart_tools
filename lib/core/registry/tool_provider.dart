import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tool_registry.dart';
import 'smart_tool_model.dart';

class ToolProvider extends ChangeNotifier {
  static const String _recentBoxName = 'recent_tools';
  
  List<String> _recent = [];

  List<SmartTool> get recentTools {
    final list = <SmartTool>[];
    for (final id in _recent) {
      final matches = ToolRegistry.allTools.where((t) => t.id == id);
      if (matches.isNotEmpty) {
        list.add(matches.first);
      }
    }
    return list.take(5).toList();
  }

  ToolProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final recentBox = await Hive.openBox<String>(_recentBoxName);
    
    // Clear existing database entries for recent tools as requested
    await recentBox.clear();
    _recent.clear();

    notifyListeners();
  }

  Future<void> addToRecent(String toolId) async {
    final box = Hive.box<String>(_recentBoxName);
    
    // Remove if already exists to move to top
    _recent.remove(toolId);
    
    // Insert at beginning
    _recent.insert(0, toolId);
    
    // Keep only last 10
    if (_recent.length > 10) {
      _recent = _recent.sublist(0, 10);
    }

    // Update Hive
    await box.clear();
    await box.addAll(_recent);
    
    notifyListeners();
  }

  /// Clears all stored recent tools from database
  Future<void> clearRecentTools() async {
    final box = Hive.box<String>(_recentBoxName);
    await box.clear();
    _recent.clear();
    notifyListeners();
  }
}
