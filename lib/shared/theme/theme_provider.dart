import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'app_theme_mode';
  final _storage = const FlutterSecureStorage();

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: _key);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else if (saved == 'system') {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    if (mode == ThemeMode.light) {
      await _storage.write(key: _key, value: 'light');
    } else if (mode == ThemeMode.dark) {
      await _storage.write(key: _key, value: 'dark');
    } else {
      await _storage.write(key: _key, value: 'system');
    }
  }
}

final themeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
