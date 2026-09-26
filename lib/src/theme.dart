import 'package:flutter/material.dart';

/// Colour roles of a theme. Widgets read them through [IvoryColors], which
/// always returns the active palette's value.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.label,
    required this.brightness,
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.success,
    required this.background,
    required this.surface,
    required this.border,
    required this.ink,
    required this.muted,
    required this.onPrimary,
    required this.onAccent,
  });

  final String id;
  final String label;
  final Brightness brightness;
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color success;
  final Color background;
  final Color surface;
  final Color border;
  final Color ink;
  final Color muted;

  /// Text and icons drawn on [primary] (header, buttons) and [accent].
  final Color onPrimary;
  final Color onAccent;

  bool get isDark => brightness == Brightness.dark;

  /// Côte d'Ivoire flag: orange, white, green (default).
  static const ivoire = AppPalette(
    id: 'ivoire',
    label: 'Ivoire',
    brightness: Brightness.light,
    primary: Color(0xFF009A44),
    primaryDark: Color(0xFF00733A),
    accent: Color(0xFFFF8200),
    success: Color(0xFF009A44),
    background: Color(0xFFF4F7F5),
    surface: Colors.white,
    border: Color(0xFFE2E8E4),
    ink: Color(0xFF1B2420),
    muted: Color(0xFF66706B),
    onPrimary: Colors.white,
    onAccent: Colors.white,
  );

  /// The Dracula dark theme (draculatheme.com).
  static const dracula = AppPalette(
    id: 'dracula',
    label: 'Dracula',
    brightness: Brightness.dark,
    primary: Color(0xFFBD93F9),
    primaryDark: Color(0xFF6272A4),
    accent: Color(0xFFFFB86C),
    success: Color(0xFF50FA7B),
    background: Color(0xFF21222C),
    surface: Color(0xFF282A36),
    border: Color(0xFF44475A),
    ink: Color(0xFFF8F8F2),
    muted: Color(0xFFA4A9C9),
    onPrimary: Color(0xFF282A36),
    onAccent: Color(0xFF282A36),
  );

  /// Ébrié lagoon: teal water and warm sand.
  static const lagune = AppPalette(
    id: 'lagune',
    label: 'Lagune',
    brightness: Brightness.light,
    primary: Color(0xFF00838F),
    primaryDark: Color(0xFF005662),
    accent: Color(0xFFE76F51),
    success: Color(0xFF2A9D8F),
    background: Color(0xFFF2F7F7),
    surface: Colors.white,
    border: Color(0xFFD8E6E7),
    ink: Color(0xFF12302F),
    muted: Color(0xFF5E7475),
    onPrimary: Colors.white,
    onAccent: Colors.white,
  );

  static const all = [ivoire, dracula, lagune];

  static AppPalette byId(String? id) =>
      all.firstWhere((palette) => palette.id == id, orElse: () => ivoire);

  /// The palette in use, set by AppSettings.
  static AppPalette current = ivoire;
}

/// Theme-aware colours. The names come from the Côte d'Ivoire palette
/// (green = primary, orange = accent) but follow the active [AppPalette].
class IvoryColors {
  static Color get orange => AppPalette.current.accent;
  static Color get green => AppPalette.current.primary;
  static Color get greenDark => AppPalette.current.primaryDark;
  static Color get success => AppPalette.current.success;
  static Color get background => AppPalette.current.background;
  static Color get surface => AppPalette.current.surface;
  static Color get border => AppPalette.current.border;
  static Color get ink => AppPalette.current.ink;
  static Color get muted => AppPalette.current.muted;
  static Color get onPrimary => AppPalette.current.onPrimary;
  static Color get onAccent => AppPalette.current.onAccent;
}

class AppTheme {
  /// Theme for the active palette ([AppPalette.current]).
  static ThemeData current() => of(AppPalette.current);

  /// Kept for existing callers; same as [current].
  static ThemeData light() => current();

  static ThemeData of(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: palette.brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.accent,
      onSecondary: palette.onAccent,
      surface: palette.surface,
      onSurface: palette.ink,
      outlineVariant: palette.border,
    );
    final rounded16 =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.surface,
      dividerColor: palette.border,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.border),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: palette.border)),
        backgroundColor: palette.surface,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: palette.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primary.withOpacity(0.16),
        elevation: 3,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.muted)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.muted)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: rounded16,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accent,
          side: BorderSide(color: palette.accent),
          minimumSize: const Size.fromHeight(48),
          shape: rounded16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: TextStyle(color: palette.surface),
      ),
    );
  }
}

/// Formats an amount as "340 000 FCFA".
String formatFcfa(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer(amount < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return '$buffer FCFA';
}
