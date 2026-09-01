import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's theme preference and persists it across launches.
///
/// The app opens in light mode; the user can switch to dark or "follow the
/// system" from the appearance settings.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initial = ThemeMode.light}) : _mode = initial;

  static const _prefsKey = 'theme_mode_v1';

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  /// Load the saved preference. Call once at startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = _decode(prefs.getString(_prefsKey));
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(mode));
  }

  static String _encode(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _decode(String? raw) => switch (raw) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };
}
