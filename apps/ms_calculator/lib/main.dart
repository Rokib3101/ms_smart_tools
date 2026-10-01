import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:calculator_features/calculator_features.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
        builder: (context, state) => const BasicCalculatorScreen(),
      ),
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
        builder: (context, state) => const UnitConverterScreen(),
      ),
      GoRoute(
        path: '/land',
        builder: (context, state) => const LandCalculatorScreen(),
      ),
      GoRoute(
        path: '/brick',
        builder: (context, state) => const BrickCalculatorScreen(),
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
