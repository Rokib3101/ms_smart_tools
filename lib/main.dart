import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ms_smart_tools/core/database/core_database.dart';
import 'package:ms_smart_tools/core/theme/theme_provider.dart';
import 'package:ms_smart_tools/core/security/app_lock_service.dart';
import 'package:ms_smart_tools/core/navigation/app_router.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';
import 'package:ms_smart_tools/features/shopping_market/models/market_models.dart';
import 'package:ms_smart_tools/features/shopping_market/models/comparator_models.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/finance_provider.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/asset_provider.dart';
import 'package:ms_smart_tools/core/registry/tool_provider.dart';
import 'package:ms_smart_tools/features/scanner/presentation/providers/scanner_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'দুঃখিত, একটি ত্রুটি ঘটেছে। অনুগ্রহ করে আবার চেষ্টা করুন।\n(Error: ${details.exception})',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  };

  await LocalPersistence.init();
  
  // Register Hive Adapters safely checking their adapter typeId
  void registerHiveAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  registerHiveAdapter(TransactionTypeAdapter());
  registerHiveAdapter(TransactionAdapter());
  registerHiveAdapter(WalletAdapter());
  registerHiveAdapter(CategoryAdapter());
  registerHiveAdapter(MarketItemAdapter());
  registerHiveAdapter(MarketListAdapter());
  registerHiveAdapter(ComparatorItemAdapter());
  registerHiveAdapter(ComparatorListAdapter());

  // Open Encrypted Finance Boxes & Standard Boxes
  await LocalPersistence.openEncryptedBox<Transaction>('transactions');
  await LocalPersistence.openEncryptedBox<Wallet>('wallets');
  await LocalPersistence.openEncryptedBox<Category>('categories');

  await Hive.openBox<String>('recent_tools');
  await Hive.openBox<MarketList>('market_lists');
  await Hive.openBox<MarketItem>('market_items');
  await Hive.openBox<ComparatorList>('comparator_lists');
  await Hive.openBox<ComparatorItem>('comparator_items');
  await Hive.openBox('assets');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => ToolProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
        ChangeNotifierProvider(create: (_) => ScannerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppLockService()),
      ],
      child: const SmartToolsApp(),
    ),
  );
}

class SmartToolsApp extends StatelessWidget {
  const SmartToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'MS Smart Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
