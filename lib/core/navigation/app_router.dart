import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../security/app_lock_guard.dart';

// Dashboard & Core
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/privacy_policy_screen.dart';

// Finance
import '../../features/finance/screens/finance_dashboard.dart';
import '../../features/finance/screens/transaction_entry_screen.dart';
import '../../features/finance/screens/transaction_history_screen.dart';
import '../../features/finance/screens/smart_insights_screen.dart';
import '../../features/finance/screens/finance_settings_screen.dart';
import '../../features/finance/screens/wallet_management_screen.dart';
import '../../features/finance/screens/category_management_screen.dart';
import '../../features/finance/screens/trash_management_screen.dart';
import '../../features/finance/screens/asset_list_screen.dart';
import '../../features/finance/screens/monthly_summary_screen.dart';

// Shopping & Market
import '../../features/shopping_market/models/market_models.dart';
import '../../features/shopping_market/models/comparator_models.dart';
import '../../features/shopping_market/presentation/screens/shopping_list_screen.dart';
import '../../features/shopping_market/presentation/screens/market_detail_screen.dart';
import '../../features/shopping_market/presentation/screens/unit_price_comparator_screen.dart';
import '../../features/shopping_market/presentation/screens/unit_price_comparator_detail_screen.dart';

// Cash counter & Calculators
import '../../features/cash_counter/presentation/screens/cash_counter_screen.dart';
import '../../features/calculators/basic_calculator/screens/calculator_screen.dart';
import '../../features/calculators/age_calculator/screens/age_calculator_screen.dart';
import '../../features/calculators/bmi_calculator/screens/bmi_calculator_screen.dart';

// Converters
import '../../features/converter/unit_converter/screens/unit_converter_screen.dart';
import '../../features/converter/unit_converter/screens/physics_converter_screen.dart';

// Utilities
import '../../features/qr_tools/presentation/screens/qr_generator_screen.dart';
import '../../features/qr_tools/presentation/screens/qr_scanner_screen.dart';
import '../../features/scanner/presentation/screens/scanner_home_screen.dart';
import '../../features/image_tools/presentation/screens/image_merge_screen.dart';
import '../../features/image_tools/presentation/screens/image_overlay_screen.dart';

abstract class AppRoutes {
  static const String dashboard = '/';
  static const String privacyPolicy = '/privacy-policy';

  // Core Tools
  static const String finance = '/finance';
  static const String financeTransactionEntry = '/finance/transaction-entry';
  static const String financeHistory = '/finance/history';
  static const String financeInsights = '/finance/insights';
  static const String financeSettings = '/finance/settings';
  static const String financeWallets = '/finance/wallets';
  static const String financeCategories = '/finance/categories';
  static const String financeTrash = '/finance/trash';
  static const String financeAssets = '/finance/assets';
  static const String financeMonthlySummary = '/finance/monthly-summary';

  static const String shoppingList = '/shopping-list';
  static const String shoppingListDetail = '/shopping-list/detail';
  static const String unitPrice = '/unit-price';
  static const String unitPriceDetail = '/unit-price/detail';

  static const String cashCounter = '/cash-counter';
  static const String calculator = '/calculator';
  static const String ageCalc = '/age-calc';
  static const String bmiCalc = '/bmi-calc';

  static const String unitConv = '/unit-conv';
  static const String physicsConv = '/physics-conv';

  static const String qrScanner = '/qr-scanner';
  static const String qrGenerator = '/qr-generator';
  static const String docScanner = '/doc-scanner';
  static const String imageMerge = '/image-merge';
  static const String imageOverlay = '/image-overlay';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // Finance
      GoRoute(
        path: AppRoutes.finance,
        builder: (context, state) => const AppLockGuard(child: FinanceDashboard()),
      ),
      GoRoute(
        path: AppRoutes.financeTransactionEntry,
        builder: (context, state) => const TransactionEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeInsights,
        builder: (context, state) => const SmartInsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeSettings,
        builder: (context, state) => const FinanceSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeWallets,
        builder: (context, state) => const WalletManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeCategories,
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeTrash,
        builder: (context, state) => const TrashManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeAssets,
        builder: (context, state) => const AssetListScreen(),
      ),
      GoRoute(
        path: AppRoutes.financeMonthlySummary,
        builder: (context, state) => const MonthlySummaryScreen(),
      ),

      // Shopping & Market
      GoRoute(
        path: AppRoutes.shoppingList,
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: AppRoutes.shoppingListDetail,
        builder: (context, state) {
          final marketList = state.extra as MarketList;
          return MarketDetailScreen(marketList: marketList);
        },
      ),
      GoRoute(
        path: AppRoutes.unitPrice,
        builder: (context, state) => const UnitPriceComparatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.unitPriceDetail,
        builder: (context, state) {
          final comparatorList = state.extra as ComparatorList;
          return UnitPriceComparatorDetailScreen(comparatorList: comparatorList);
        },
      ),

      // Cash Counter & Calculators
      GoRoute(
        path: AppRoutes.cashCounter,
        builder: (context, state) => const CashCounterScreen(),
      ),
      GoRoute(
        path: AppRoutes.calculator,
        builder: (context, state) => const CalculatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.ageCalc,
        builder: (context, state) => const AgeCalculatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.bmiCalc,
        builder: (context, state) => const BmiCalculatorScreen(),
      ),

      // Converters
      GoRoute(
        path: AppRoutes.unitConv,
        builder: (context, state) => const UnitConverterScreen(),
      ),
      GoRoute(
        path: AppRoutes.physicsConv,
        builder: (context, state) => const PhysicsConverterScreen(),
      ),

      // Utilities
      GoRoute(
        path: AppRoutes.qrScanner,
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.qrGenerator,
        builder: (context, state) => const QrGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.docScanner,
        builder: (context, state) => const ScannerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.imageMerge,
        builder: (context, state) => const ImageMergeScreen(),
      ),
      GoRoute(
        path: AppRoutes.imageOverlay,
        builder: (context, state) => const ImageOverlayScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}
