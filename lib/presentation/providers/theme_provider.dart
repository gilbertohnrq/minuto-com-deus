import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode state
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme state notifier
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';
  static const String _hasInitializedKey = 'theme_initialized';
  bool _isInitialized = false;

  /// Check if the notifier has been initialized
  bool get isInitialized => _isInitialized;

  /// Load theme from shared preferences or detect system default
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasInitialized = prefs.getBool(_hasInitializedKey) ?? false;

      if (!hasInitialized) {
        // First time app launch - use system theme as default
        state = AppThemeMode.system;
        await _saveTheme(AppThemeMode.system);
        await prefs.setBool(_hasInitializedKey, true);
      } else {
        // Load saved theme preference
        final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
        state = AppThemeMode.values[themeIndex];
      }
    } catch (e) {
      // Default to system theme if loading fails
      state = AppThemeMode.system;
    } finally {
      _isInitialized = true;
    }
  }

  /// Save theme to shared preferences
  Future<void> _saveTheme(AppThemeMode theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Set theme mode
  Future<void> setTheme(AppThemeMode theme) async {
    state = theme;
    await _saveTheme(theme);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    AppThemeMode newTheme;
    switch (state) {
      case AppThemeMode.light:
        newTheme = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        newTheme = AppThemeMode.light;
        break;
      case AppThemeMode.system:
        // If currently system, toggle to opposite of current system brightness
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        newTheme = brightness == Brightness.dark
            ? AppThemeMode.light
            : AppThemeMode.dark;
        break;
    }
    await setTheme(newTheme);
  }

  /// Get the actual theme mode considering system settings
  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get theme mode display name
  String get displayName {
    switch (state) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Escuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }

  /// Reset theme detection (useful for testing or first-time setup)
  Future<void> resetThemeDetection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasInitializedKey);
      await prefs.remove(_themeKey);
      await _loadTheme();
    } catch (e) {
      // Silently fail if reset fails
    }
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

/// Current theme mode provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final currentTheme = ref.watch(themeProvider);
  return switch (currentTheme) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
});

/// Is dark mode provider (for UI components that need to know current brightness)
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(currentThemeModeProvider);

  // For system theme, we can't determine without BuildContext
  // This will be handled in the widget level
  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      return false; // Default to light, actual detection happens in widgets
  }
});

/// Theme display name provider
final themeDisplayNameProvider = Provider<String>((ref) {
  final currentTheme = ref.watch(themeProvider);
  switch (currentTheme) {
    case AppThemeMode.light:
      return 'Claro';
    case AppThemeMode.dark:
      return 'Escuro';
    case AppThemeMode.system:
      return 'Sistema';
  }
});
