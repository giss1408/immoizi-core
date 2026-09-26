import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/tr.dart';
import '../theme.dart';

/// Theme and language chosen by the user, remembered on the device.
/// MaterialApp listens to it and rebuilds when either changes.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final instance = AppSettings._();

  static const _themeKey = 'settings_theme';
  static const _languageKey = 'settings_language';

  AppPalette get palette => AppPalette.current;
  AppLanguage get language => AppStrings.language;
  Locale get locale => Locale(language.code);

  static const supportedLocales = [Locale('fr'), Locale('en')];
  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Restores the saved choices; call before runApp.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      AppPalette.current = AppPalette.byId(prefs.getString(_themeKey));
      AppStrings.language = AppLanguage.byCode(prefs.getString(_languageKey));
    } catch (_) {
      // Defaults (Ivoire, French) when preferences are unavailable.
    }
  }

  Future<void> setPalette(AppPalette palette) async {
    if (palette.id == AppPalette.current.id) return;
    AppPalette.current = palette;
    notifyListeners();
    await _save(_themeKey, palette.id);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == AppStrings.language) return;
    AppStrings.language = language;
    notifyListeners();
    await _save(_languageKey, language.code);
  }

  Future<void> _save(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {
      // The choice still applies until the app restarts.
    }
  }
}
