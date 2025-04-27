import 'package:flutter/material.dart';

// Provider class to manage the app's theme (light/dark/system)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Current theme mode

  // Getter to access the current theme mode
  ThemeMode get themeMode => _themeMode;

  // Toggle between light and dark themes and notify listeners
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
