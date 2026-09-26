import 'package:flutter/material.dart';

import '../i18n/tr.dart';
import '../theme.dart';
import 'app_settings.dart';

/// "Préférences" section of Mon espace: theme and interface language.
class PreferencesCard extends StatelessWidget {
  const PreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.tune, color: IvoryColors.green),
                const SizedBox(width: 10),
                Text(tr('Préférences'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: IvoryColors.ink)),
              ]),
              const SizedBox(height: 16),
              Text(tr('Thème'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: IvoryColors.ink)),
              const SizedBox(height: 10),
              Row(children: [
                for (final palette in AppPalette.all) ...[
                  Expanded(
                    child: _ThemeSwatch(
                      palette: palette,
                      selected: palette.id == settings.palette.id,
                      onTap: () => settings.setPalette(palette),
                    ),
                  ),
                  if (palette != AppPalette.all.last) const SizedBox(width: 10),
                ],
              ]),
              const SizedBox(height: 18),
              Text(tr('Langue'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: IvoryColors.ink)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AppLanguage>(
                  segments: [
                    for (final language in AppLanguage.values)
                      ButtonSegment(
                          value: language,
                          label: Text(language.label),
                          icon: Text(
                              language == AppLanguage.fr ? '🇫🇷' : '🇬🇧')),
                  ],
                  selected: {settings.language},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      settings.setLanguage(selection.first),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch(
      {required this.palette, required this.selected, required this.onTap});

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tr('Thème {name}', {'name': palette.label}),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? IvoryColors.green : palette.border,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(children: [
            Container(
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [palette.primary, palette.primaryDark]),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                    color: palette.accent, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (selected) ...[
                Icon(Icons.check_circle, size: 14, color: palette.primary),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(palette.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: palette.ink)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
