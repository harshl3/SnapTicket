import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system('System Default', ThemeMode.system),
  light('Light', ThemeMode.light),
  dark('Dark', ThemeMode.dark);

  final String label;
  final ThemeMode mode;
  const AppThemeMode(this.label, this.mode);
}

class ThemeProvider extends ChangeNotifier {
  static const String _prefThemeKey = 'selected_theme_mode';
  AppThemeMode _currentThemeMode = AppThemeMode.dark;

  AppThemeMode get currentThemeMode => _currentThemeMode;
  ThemeMode get themeMode => _currentThemeMode.mode;

  bool get isDarkMode {
    if (_currentThemeMode == AppThemeMode.dark) return true;
    if (_currentThemeMode == AppThemeMode.light) return false;
    final window = WidgetsBinding.instance.platformDispatcher;
    return window.platformBrightness == Brightness.dark;
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefThemeKey);
      if (savedMode != null) {
        _currentThemeMode = AppThemeMode.values.firstWhere(
          (m) => m.name == savedMode,
          orElse: () => AppThemeMode.dark,
        );
        notifyListeners();
      }
    } catch (_) {
      // Fallback to dark if prefs fail
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentThemeMode == mode) return;
    _currentThemeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefThemeKey, mode.name);
    } catch (_) {}
  }
}
