import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ms_smart_tools/core/database/core_database.dart';
import 'package:ms_smart_tools/core/theme/theme_provider.dart';
import 'package:ms_smart_tools/core/security/app_lock_service.dart';
import 'package:ms_smart_tools/core/security/app_lock_guard.dart';
import 'package:ms_smart_tools/features/finance/data/models/finance_models.dart';
import 'package:ms_smart_tools/features/shopping_market/models/market_models.dart';
import 'package:ms_smart_tools/features/shopping_market/models/comparator_models.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/finance_provider.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/asset_provider.dart';
import 'package:ms_smart_tools/features/finance/screens/finance_home_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/finance_dashboard.dart';
import 'package:ms_smart_tools/features/finance/screens/finance_settings_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/transaction_entry_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/transaction_history_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/smart_insights_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/wallet_management_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/category_management_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/trash_management_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/asset_list_screen.dart';
import 'package:ms_smart_tools/features/finance/screens/monthly_summary_screen.dart';
import 'package:ms_smart_tools/features/cash_counter/presentation/screens/cash_counter_screen.dart';
import 'package:ms_smart_tools/features/shopping_market/presentation/screens/shopping_list_screen.dart';
import 'package:ms_smart_tools/features/shopping_market/presentation/screens/unit_price_comparator_screen.dart';
import 'package:ms_smart_tools/features/shopping_market/presentation/screens/market_detail_screen.dart';
import 'package:ms_smart_tools/features/shopping_market/presentation/screens/unit_price_comparator_detail_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/about_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/social_media_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/privacy_policy_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('MS Finance Error: ${details.exception}');
  };

  await LocalPersistence.init();

  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  registerAdapter(TransactionTypeAdapter());
  registerAdapter(TransactionAdapter());
  registerAdapter(WalletAdapter());
  registerAdapter(CategoryAdapter());
  registerAdapter(MarketItemAdapter());
  registerAdapter(MarketListAdapter());
  registerAdapter(ComparatorItemAdapter());
  registerAdapter(ComparatorListAdapter());

  await LocalPersistence.openEncryptedBox<Transaction>('transactions');
  await LocalPersistence.openEncryptedBox<Wallet>('wallets');
  await LocalPersistence.openEncryptedBox<Category>('categories');

  await Hive.openBox<MarketList>('market_lists');
  await Hive.openBox<MarketItem>('market_items');
  await Hive.openBox<ComparatorList>('comparator_lists');
  await Hive.openBox<ComparatorItem>('comparator_items');
  await Hive.openBox('assets');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppLockService()),
      ],
      child: const MSFinanceApp(),
    ),
  );
}

class MSFinanceApp extends StatelessWidget {
  const MSFinanceApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FinanceHomeScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/social-media',
        builder: (context, state) => const SocialMediaScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const AppLockGuard(child: FinanceDashboard()),
      ),
      GoRoute(
        path: '/cash-counter',
        builder: (context, state) => const CashCounterScreen(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: '/shopping-list',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: '/comparator',
        builder: (context, state) => const UnitPriceComparatorScreen(),
      ),
      GoRoute(
        path: '/unit-price',
        builder: (context, state) => const UnitPriceComparatorScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const FinanceSettingsScreen(),
      ),
      GoRoute(
        path: '/finance/settings',
        builder: (context, state) => const FinanceSettingsScreen(),
      ),
      GoRoute(
        path: '/finance/transaction-entry',
        builder: (context, state) => const TransactionEntryScreen(),
      ),
      GoRoute(
        path: '/finance/history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/finance/insights',
        builder: (context, state) => const SmartInsightsScreen(),
      ),
      GoRoute(
        path: '/finance/wallets',
        builder: (context, state) => const WalletManagementScreen(),
      ),
      GoRoute(
        path: '/finance/categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/finance/trash',
        builder: (context, state) => const TrashManagementScreen(),
      ),
      GoRoute(
        path: '/finance/assets',
        builder: (context, state) => const AssetListScreen(),
      ),
      GoRoute(
        path: '/finance/monthly-summary',
        builder: (context, state) => const MonthlySummaryScreen(),
      ),
      GoRoute(
        path: '/shopping-list/detail',
        builder: (context, state) {
          final list = state.extra as MarketList;
          return MarketDetailScreen(marketList: list);
        },
      ),
      GoRoute(
        path: '/unit-price/detail',
        builder: (context, state) {
          final list = state.extra as ComparatorList;
          return UnitPriceComparatorDetailScreen(comparatorList: list);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'MS Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
