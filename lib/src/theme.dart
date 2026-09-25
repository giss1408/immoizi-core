import 'package:flutter/material.dart';

/// Côte d'Ivoire palette: orange, white, green.
class IvoryColors {
  static const Color orange = Color(0xFFFF8200);
  static const Color green = Color(0xFF009A44);
  static const Color greenDark = Color(0xFF00733A);
  static const Color background = Color(0xFFF4F7F5);
  static const Color border = Color(0xFFE2E8E4);
  static const Color ink = Color(0xFF1B2420);
  static const Color muted = Color(0xFF66706B);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: IvoryColors.green,
      primary: IvoryColors.green,
      secondary: IvoryColors.orange,
      surface: Colors.white,
      outlineVariant: IvoryColors.border,
    );
    final rounded16 =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: IvoryColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: IvoryColors.green,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: IvoryColors.border),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: IvoryColors.border)),
        backgroundColor: Colors.white,
        labelStyle:
            TextStyle(fontWeight: FontWeight.w600, color: IvoryColors.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: IvoryColors.green.withOpacity(0.14),
        elevation: 3,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? IvoryColors.green
                : IvoryColors.muted)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? IvoryColors.green
                : IvoryColors.muted)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: IvoryColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: rounded16,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: IvoryColors.orange,
          side: const BorderSide(color: IvoryColors.orange),
          minimumSize: const Size.fromHeight(48),
          shape: rounded16,
        ),
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
