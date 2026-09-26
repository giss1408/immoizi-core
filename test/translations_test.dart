import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:immoizi_core/immoizi_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every literal passed to tr() under [dir], decoded like Dart would.
Set<String> trKeys(String dir) {
  // Single- or double-quoted Dart literal; the text is group 1 or 2.
  const literal = r"""(?:'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)")""";
  final direct = RegExp(r'(?<![\w.])tr\(\s*' + literal);
  final ternary = RegExp(
      r'(?<![\w.])tr\(\s*[^,()]*?\?\s*' + literal + r'\s*:\s*' + literal);
  String decode(String s) => s
      .replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'),
          (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)))
      .replaceAll(r"\'", "'")
      .replaceAll(r'\$', r'$');
  final keys = <String>{};
  for (final file in Directory(dir).listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.dart')) continue;
    final source = file.readAsStringSync();
    for (final m in direct.allMatches(source)) {
      keys.add(decode(m[1] ?? m[2]!));
    }
    for (final m in ternary.allMatches(source)) {
      keys
        ..add(decode(m[1] ?? m[2]!))
        ..add(decode(m[3] ?? m[4]!));
    }
  }
  return keys;
}

void main() {
  tearDown(() => AppStrings.language = AppLanguage.fr);

  test('every tr() string in the core has an English translation', () {
    final missing =
        trKeys('lib').where((key) => !AppStrings.hasTranslation(key)).toList();
    expect(missing, isEmpty);
  });

  test('tr translates and fills placeholders', () {
    expect(tr('Envoyer'), 'Envoyer');
    AppStrings.language = AppLanguage.en;
    expect(tr('Envoyer'), 'Send');
    expect(tr('{count} pièces', {'count': 3}), '3 rooms');
    expect(tr('Texte sans traduction'), 'Texte sans traduction');
  });

  test('status and rental labels follow the language', () {
    AppStrings.language = AppLanguage.en;
    expect(listingStatusLabel('AVAILABLE'), 'Available');
    expect(interestStatusLabel('PENDING', expired: true), 'Expired');
    expect(RentalType.shortTerm.label, 'Short stay');
    expect(
        Property('T', 'R', 'A', 'B', 1, 1, 35000,
                rentalType: RentalType.shortTerm)
            .priceLabel,
        '35 000 FCFA / night');
    expect(describeError(const NetworkException()),
        'Server unreachable — check your connection.');
  });

  test('palettes give a dark theme for Dracula', () {
    final dracula = AppTheme.of(AppPalette.dracula);
    expect(dracula.brightness, Brightness.dark);
    expect(dracula.scaffoldBackgroundColor, AppPalette.dracula.background);
    expect(AppPalette.byId('lagune'), AppPalette.lagune);
    expect(AppPalette.byId('unknown'), AppPalette.ivoire);
  });

  test('settings remember the theme and language', () async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.setPalette(AppPalette.dracula);
    await AppSettings.instance.setLanguage(AppLanguage.en);
    AppPalette.current = AppPalette.ivoire;
    AppStrings.language = AppLanguage.fr;

    await AppSettings.instance.load();
    expect(AppPalette.current, AppPalette.dracula);
    expect(AppStrings.language, AppLanguage.en);
    AppPalette.current = AppPalette.ivoire;
  });

  testWidgets('available listings keep a green dot in English', (tester) async {
    AppStrings.language = AppLanguage.en;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PropertyListingCard(
              Property('T', 'Residence', 'Abidjan', 'Cocody', 2, 60, 300000),
              statusLabel: listingStatusLabel('AVAILABLE'),
              onTap: () {}),
        ),
      ),
    ));
    final dot = tester.widget<Icon>(find.byIcon(Icons.circle));
    expect(dot.color, IvoryColors.success);
  });
}
