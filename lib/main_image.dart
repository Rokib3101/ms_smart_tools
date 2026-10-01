import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ms_smart_tools/core/theme/theme_provider.dart';
import 'package:ms_smart_tools/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:ms_smart_tools/features/qr_tools/presentation/screens/qr_scanner_screen.dart';
import 'package:ms_smart_tools/features/qr_tools/presentation/screens/qr_generator_screen.dart';
import 'package:ms_smart_tools/features/scanner/presentation/screens/scanner_home_screen.dart';
import 'package:ms_smart_tools/features/image_tools/presentation/screens/image_merge_screen.dart';
import 'package:ms_smart_tools/features/image_tools/presentation/screens/image_overlay_screen.dart';
import 'package:ms_smart_tools/features/image_tools/presentation/screens/ms_image_dashboard.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/about_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/social_media_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/privacy_policy_screen.dart';
import 'package:ms_smart_tools/features/dashboard/presentation/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ScannerProvider()),
      ],
      child: const MSImageApp(),
    ),
  );
}

class MSImageApp extends StatelessWidget {
  const MSImageApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MSImageDashboard(),
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
        path: '/qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/qr-generator',
        builder: (context, state) => const QrGeneratorScreen(),
      ),
      GoRoute(
        path: '/qr-gen',
        builder: (context, state) => const QrGeneratorScreen(),
      ),
      GoRoute(
        path: '/doc-scanner',
        builder: (context, state) => const ScannerHomeScreen(),
      ),
      GoRoute(
        path: '/doc-scan',
        builder: (context, state) => const ScannerHomeScreen(),
      ),
      GoRoute(
        path: '/image-merge',
        builder: (context, state) => const ImageMergeScreen(),
      ),
      GoRoute(
        path: '/image-overlay',
        builder: (context, state) => const ImageOverlayScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'MS Image',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
