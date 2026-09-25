import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5),
        secondary: const Color(0xFF26A69A),
        surface: const Color(0xFFF5F7FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      textTheme: GoogleFonts.anekBanglaTextTheme(),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.anekBangla(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5),
        brightness: Brightness.dark,
        secondary: const Color(0xFF26A69A),
        surface: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.anekBanglaTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        titleTextStyle: GoogleFonts.anekBangla(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
