import 'core_strings.dart';

/// Interface languages. French is the source language of every string.
enum AppLanguage {
  fr('fr', 'Français'),
  en('en', 'English');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  static AppLanguage byCode(String? code) =>
      values.firstWhere((language) => language.code == code, orElse: () => fr);
}

/// French → English dictionary. The core registers its strings; each app
/// adds its own with [AppStrings.register].
class AppStrings {
  AppStrings._();

  static AppLanguage language = AppLanguage.fr;
  static final Map<String, String> _english = {...coreEnglish};

  static void register(Map<String, String> english) => _english.addAll(english);

  /// Every registered French source string (used by tests).
  static Iterable<String> get keys => _english.keys;

  static bool hasTranslation(String french) => _english.containsKey(french);

  static String translate(String french) =>
      language == AppLanguage.en ? (_english[french] ?? french) : french;
}

/// Translates a French interface string to the active language.
/// Placeholders such as `{date}` are filled from [args].
String tr(String french, [Map<String, Object?> args = const {}]) {
  var text = AppStrings.translate(french);
  args.forEach((key, value) => text = text.replaceAll('{$key}', '$value'));
  return text;
}
