import 'package:flutter/material.dart';

import 'i18n/tr.dart';
import 'settings/app_settings.dart';
import 'theme.dart';

/// Loads the saved settings, then runs [app].
Future<void> runImmoiziApp(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  runApp(app);
}

/// MaterialApp that follows the chosen theme and language.
class ImmoiziApp extends StatelessWidget {
  const ImmoiziApp(
      {required this.title,
      required this.translations,
      required this.home,
      super.key});

  final String title;

  /// The app's own English strings, on top of the core ones.
  final Map<String, String> translations;

  /// Called on every theme or language change so the whole UI picks it up.
  final WidgetBuilder home;

  @override
  Widget build(BuildContext context) {
    AppStrings.register(translations);
    // Rebuilds the whole app when the theme or language changes.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: AppTheme.current(),
        locale: AppSettings.instance.locale,
        supportedLocales: AppSettings.supportedLocales,
        localizationsDelegates: AppSettings.localizationsDelegates,
        home: Builder(builder: home),
      ),
    );
  }
}
