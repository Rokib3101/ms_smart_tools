import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ms_smart_tools/core/theme/theme_provider.dart';
import 'package:ms_smart_tools/core/registry/tool_provider.dart';
import 'package:ms_smart_tools/features/calculators/basic_calculator/screens/calculator_screen.dart';
import 'package:ms_smart_tools/features/calculators/basic_calculator/screens/converter_list_screen.dart';
import 'package:ms_smart_tools/features/calculators/age_calculator/screens/age_calculator_screen.dart';
import 'package:ms_smart_tools/features/calculators/bmi_calculator/screens/bmi_calculator_screen.dart';
import 'package:ms_smart_tools/features/converter/screens/single_converter_screen.dart';
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
        ChangeNotifierProvider(create: (_) => ToolProvider()),
      ],
      child: const MSCalculatorApp(),
    ),
  );
}

class MSCalculatorApp extends StatelessWidget {
  const MSCalculatorApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CalculatorScreen(),
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
        path: '/converter-list',
        builder: (context, state) => const ConverterListScreen(),
      ),
      GoRoute(
        path: '/age-calc',
        builder: (context, state) => const AgeCalculatorScreen(),
      ),
      GoRoute(
        path: '/bmi-calc',
        builder: (context, state) => const BmiCalculatorScreen(),
      ),
      GoRoute(
        path: '/converter/length',
        builder: (context, state) => const SingleConverterScreen(type: 'length'),
      ),
      GoRoute(
        path: '/converter/area',
        builder: (context, state) => const SingleConverterScreen(type: 'area'),
      ),
      GoRoute(
        path: '/converter/volume',
        builder: (context, state) => const SingleConverterScreen(type: 'volume'),
      ),
      GoRoute(
        path: '/converter/mass',
        builder: (context, state) => const SingleConverterScreen(type: 'mass'),
      ),
      GoRoute(
        path: '/converter/temp',
        builder: (context, state) => const SingleConverterScreen(type: 'temp'),
      ),
      GoRoute(
        path: '/converter/time',
        builder: (context, state) => const SingleConverterScreen(type: 'time'),
      ),
      GoRoute(
        path: '/converter/speed',
        builder: (context, state) => const SingleConverterScreen(type: 'speed'),
      ),
      GoRoute(
        path: '/converter/pressure',
        builder: (context, state) => const SingleConverterScreen(type: 'pressure'),
      ),
      GoRoute(
        path: '/converter/energy',
        builder: (context, state) => const SingleConverterScreen(type: 'energy'),
      ),
      // Aliases for legacy paths
      GoRoute(
        path: '/age',
        builder: (context, state) => const AgeCalculatorScreen(),
      ),
      GoRoute(
        path: '/bmi',
        builder: (context, state) => const BmiCalculatorScreen(),
      ),
      GoRoute(
        path: '/unit',
        builder: (context, state) => const SingleConverterScreen(type: 'length'),
      ),
      GoRoute(
        path: '/physics',
        builder: (context, state) => const SingleConverterScreen(type: 'speed'),
      ),
      GoRoute(
        path: '/unit-conv',
        builder: (context, state) => const SingleConverterScreen(type: 'length'),
      ),
      GoRoute(
        path: '/physics-conv',
        builder: (context, state) => const SingleConverterScreen(type: 'speed'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'MS Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
