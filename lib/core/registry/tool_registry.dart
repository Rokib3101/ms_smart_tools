import 'package:flutter/material.dart';
import 'smart_tool_model.dart';

// Import security guard
import '../security/app_lock_guard.dart';

// Import all screens
import '../../features/finance/screens/finance_dashboard.dart';
import '../../features/cash_counter/presentation/screens/cash_counter_screen.dart';
import '../../features/calculators/basic_calculator/screens/calculator_screen.dart';
import '../../features/calculators/age_calculator/screens/age_calculator_screen.dart';
import '../../features/calculators/bmi_calculator/screens/bmi_calculator_screen.dart';
import '../../features/qr_tools/presentation/screens/qr_generator_screen.dart';
import '../../features/qr_tools/presentation/screens/qr_scanner_screen.dart';
import '../../features/shopping_market/presentation/screens/unit_price_comparator_screen.dart';
import '../../features/shopping_market/presentation/screens/shopping_list_screen.dart';
import '../../features/converter/screens/single_converter_screen.dart';
import '../../features/image_tools/presentation/screens/image_merge_screen.dart';
import '../../features/image_tools/presentation/screens/image_overlay_screen.dart';
import '../../features/scanner/presentation/screens/scanner_home_screen.dart';

class ToolRegistry {
  static final List<SmartTool> allTools = [
    // Finance
    const SmartTool(
      id: 'finance',
      titleBn: 'Personal Finance',
      titleEn: 'Personal Finance',
      category: ToolCategory.finance,
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
      keywords: ['money', 'finance', 'budget', 'expense', 'income', 'bank', 'wallet'],
      screen: AppLockGuard(child: FinanceDashboard()),
      route: '/finance',
      analyticsEventName: 'tool_open_finance',
    ),
    const SmartTool(
      id: 'shopping_list',
      titleBn: 'Shopping List',
      titleEn: 'Shopping List',
      category: ToolCategory.finance,
      icon: Icons.shopping_cart,
      color: Colors.blueAccent,
      keywords: ['shopping', 'checklist', 'list', 'todo', 'buy', 'market'],
      screen: ShoppingListScreen(),
      route: '/shopping-list',
      analyticsEventName: 'tool_open_shopping_list',
    ),
    const SmartTool(
      id: 'cash_counter',
      titleBn: 'Cash Counter',
      titleEn: 'Cash Counter',
      category: ToolCategory.finance,
      icon: Icons.money,
      color: Colors.green,
      keywords: ['cash', 'counter', 'money', 'notes', 'currency', 'taka'],
      screen: CashCounterScreen(),
      route: '/cash-counter',
      analyticsEventName: 'tool_open_cash_counter',
    ),

    // Calculators
    const SmartTool(
      id: 'unit_price',
      titleBn: 'Price Comparator',
      titleEn: 'Price Comparator',
      category: ToolCategory.finance,
      icon: Icons.price_check,
      color: Colors.purple,
      keywords: ['shopping', 'compare', 'price', 'cheap', 'unit'],
      screen: UnitPriceComparatorScreen(),
      route: '/unit-price',
      analyticsEventName: 'tool_open_unit_price',
    ),
    const SmartTool(
      id: 'calculator',
      titleBn: 'Calculator',
      titleEn: 'Calculator',
      category: ToolCategory.calculator,
      icon: Icons.calculate,
      color: Colors.orange,
      keywords: ['math', 'calculator', 'basic', 'count'],
      screen: CalculatorScreen(),
      route: '/calculator',
      analyticsEventName: 'tool_open_calculator',
    ),
    const SmartTool(
      id: 'age_calc',
      titleBn: 'Age Calculator',
      titleEn: 'Age Calculator',
      category: ToolCategory.calculator,
      icon: Icons.cake,
      color: Colors.pink,
      keywords: ['birthday', 'age', 'date', 'calc'],
      screen: AgeCalculatorScreen(),
      route: '/age-calc',
      analyticsEventName: 'tool_open_age_calc',
    ),
    const SmartTool(
      id: 'bmi_calc',
      titleBn: 'BMI Calculator',
      titleEn: 'BMI Calculator',
      category: ToolCategory.calculator,
      icon: Icons.monitor_weight,
      color: Colors.green,
      keywords: ['health', 'weight', 'body', 'bmi', 'fitness'],
      screen: BmiCalculatorScreen(),
      route: '/bmi-calc',
      analyticsEventName: 'tool_open_bmi_calc',
    ),

    // Converters (after BMI Calculator)
    const SmartTool(
      id: 'converter_length',
      titleBn: 'Length',
      titleEn: 'Length',
      category: ToolCategory.converter,
      icon: Icons.straighten,
      color: Colors.deepOrange,
      keywords: ['length', 'meter', 'km', 'feet', 'inch', 'converter'],
      screen: SingleConverterScreen(type: 'length'),
      route: '/converter/length',
      analyticsEventName: 'tool_open_converter_length',
    ),
    const SmartTool(
      id: 'converter_area',
      titleBn: 'Area',
      titleEn: 'Area',
      category: ToolCategory.converter,
      icon: Icons.square_foot,
      color: Colors.green,
      keywords: ['area', 'land', 'decimal', 'katha', 'bigha', 'acre', 'converter'],
      screen: SingleConverterScreen(type: 'area'),
      route: '/converter/area',
      analyticsEventName: 'tool_open_converter_area',
    ),
    const SmartTool(
      id: 'converter_volume',
      titleBn: 'Volume',
      titleEn: 'Volume',
      category: ToolCategory.converter,
      icon: Icons.opacity,
      color: Colors.pink,
      keywords: ['volume', 'liquid', 'liter', 'ml', 'gallon', 'converter'],
      screen: SingleConverterScreen(type: 'volume'),
      route: '/converter/volume',
      analyticsEventName: 'tool_open_converter_volume',
    ),
    const SmartTool(
      id: 'converter_mass',
      titleBn: 'Mass',
      titleEn: 'Mass',
      category: ToolCategory.converter,
      icon: Icons.scale,
      color: Colors.indigo,
      keywords: ['mass', 'weight', 'kg', 'gram', 'pound', 'ton', 'converter'],
      screen: SingleConverterScreen(type: 'mass'),
      route: '/converter/mass',
      analyticsEventName: 'tool_open_converter_mass',
    ),
    const SmartTool(
      id: 'converter_temp',
      titleBn: 'Temperature',
      titleEn: 'Temperature',
      category: ToolCategory.converter,
      icon: Icons.thermostat,
      color: Colors.orange,
      keywords: ['temperature', 'celsius', 'fahrenheit', 'kelvin', 'converter'],
      screen: SingleConverterScreen(type: 'temp'),
      route: '/converter/temp',
      analyticsEventName: 'tool_open_converter_temp',
    ),
    const SmartTool(
      id: 'converter_time',
      titleBn: 'Time',
      titleEn: 'Time',
      category: ToolCategory.converter,
      icon: Icons.timer,
      color: Colors.blue,
      keywords: ['time', 'second', 'minute', 'hour', 'day', 'year', 'converter'],
      screen: SingleConverterScreen(type: 'time'),
      route: '/converter/time',
      analyticsEventName: 'tool_open_converter_time',
    ),
    const SmartTool(
      id: 'converter_speed',
      titleBn: 'Speed',
      titleEn: 'Speed',
      category: ToolCategory.converter,
      icon: Icons.speed,
      color: Colors.red,
      keywords: ['speed', 'kmh', 'ms', 'mph', 'converter'],
      screen: SingleConverterScreen(type: 'speed'),
      route: '/converter/speed',
      analyticsEventName: 'tool_open_converter_speed',
    ),
    const SmartTool(
      id: 'converter_pressure',
      titleBn: 'Pressure',
      titleEn: 'Pressure',
      category: ToolCategory.converter,
      icon: Icons.compress,
      color: Colors.purple,
      keywords: ['pressure', 'pa', 'bar', 'psi', 'converter'],
      screen: SingleConverterScreen(type: 'pressure'),
      route: '/converter/pressure',
      analyticsEventName: 'tool_open_converter_pressure',
    ),
    const SmartTool(
      id: 'converter_energy',
      titleBn: 'Energy',
      titleEn: 'Energy',
      category: ToolCategory.converter,
      icon: Icons.electric_bolt,
      color: Colors.indigo,
      keywords: ['energy', 'power', 'watt', 'joule', 'calorie', 'kwh', 'converter'],
      screen: SingleConverterScreen(type: 'energy'),
      route: '/converter/energy',
      analyticsEventName: 'tool_open_converter_energy',
    ),

    // Utilities
    const SmartTool(
      id: 'qr_scanner',
      titleBn: 'QR Scanner',
      titleEn: 'QR Scanner',
      category: ToolCategory.utility,
      icon: Icons.qr_code_scanner,
      color: Colors.teal,
      keywords: ['scan', 'code', 'qr', 'barcode', 'gallery'],
      screen: QrScannerScreen(),
      route: '/qr-scanner',
      requiresCamera: true,
      analyticsEventName: 'tool_open_qr_scanner',
    ),
    const SmartTool(
      id: 'qr_generator',
      titleBn: 'QR Generator',
      titleEn: 'QR Generator',
      category: ToolCategory.utility,
      icon: Icons.qr_code,
      color: Colors.indigo,
      keywords: ['create', 'code', 'qr', 'make', 'wifi'],
      screen: QrGeneratorScreen(),
      route: '/qr-generator',
      requiresStorage: true,
      analyticsEventName: 'tool_open_qr_generator',
    ),
    const SmartTool(
      id: 'doc_scanner',
      titleBn: 'Document Scanner',
      titleEn: 'Document Scanner',
      category: ToolCategory.utility,
      icon: Icons.document_scanner,
      color: Colors.deepPurple,
      keywords: ['scanner', 'doc', 'document', 'crop', 'gallery', 'pdf'],
      screen: ScannerHomeScreen(),
      route: '/doc-scanner',
      requiresCamera: true,
      requiresStorage: true,
      analyticsEventName: 'tool_open_doc_scanner',
    ),
    const SmartTool(
      id: 'image_merge',
      titleBn: 'Image Merge',
      titleEn: 'Image Merge',
      category: ToolCategory.utility,
      icon: Icons.call_merge,
      color: Colors.blue,
      keywords: ['image', 'merge', 'join', 'combine'],
      screen: ImageMergeScreen(),
      route: '/image-merge',
      requiresStorage: true,
      analyticsEventName: 'tool_open_image_merge',
    ),
    const SmartTool(
      id: 'image_overlay',
      titleBn: 'Image Overlay',
      titleEn: 'Image Overlay',
      category: ToolCategory.utility,
      icon: Icons.layers,
      color: Colors.teal,
      keywords: ['image', 'overlay', 'layers'],
      screen: ImageOverlayScreen(),
      route: '/image-overlay',
      requiresStorage: true,
      analyticsEventName: 'tool_open_image_overlay',
    ),
  ];

  static const Set<String> triangleToolIds = {
    'age_calc',
    'bmi_calc',
    'converter_length',
    'converter_area',
    'converter_volume',
    'converter_mass',
    'converter_temp',
    'converter_time',
    'converter_speed',
    'converter_pressure',
    'converter_energy',
  };

  static List<SmartTool> get mainMenuTools =>
      allTools.where((t) => !triangleToolIds.contains(t.id)).toList();

  static List<SmartTool> get triangleTools =>
      allTools.where((t) => triangleToolIds.contains(t.id)).toList();

  static SmartTool? getById(String id) {
    try {
      return allTools.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<SmartTool> getByCategory(ToolCategory category) {
    return allTools.where((t) => t.category == category).toList();
  }

  static List<SmartTool> getToolsRequiringCamera() {
    return allTools.where((t) => t.requiresCamera).toList();
  }

  static List<SmartTool> getToolsRequiringStorage() {
    return allTools.where((t) => t.requiresStorage).toList();
  }

  static List<SmartTool> search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return allTools.where((t) {
      return t.titleBn.toLowerCase().contains(q) ||
             t.titleEn.toLowerCase().contains(q) ||
             t.keywords.any((k) => k.contains(q));
    }).toList();
  }
}
