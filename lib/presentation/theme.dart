import 'package:flutter/material.dart';

/// Direction artistique « à la française » : bleu nuit, ivoire, filets or,
/// chiffres et titres en Playfair Display. Sobriété, espace, matière.
abstract final class AppTheme {
  static const nuit = Color(0xFF121830); // bleu nuit
  static const encre = Color(0xFF1C2440); // encre marine
  static const ivoire = Color(0xFFF7F2E7);
  static const creme = Color(0xFFFDFBF5);
  static const or = Color(0xFFC9A227); // accent doré
  static const orSombre = Color(0xFFA8871F);
  static const carmin = Color(0xFF9E2B25); // boss
  static const brume = Color(0xFFE9E2D2); // surfaces claires

  static const gold = or;
  static const boss = carmin;

  /// Titres et grands chiffres.
  static const displayFont = 'Playfair';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: encre,
      brightness: Brightness.light,
    ).copyWith(
      primary: encre,
      onPrimary: ivoire,
      secondary: orSombre,
      surface: creme,
      onSurface: nuit,
      surfaceContainerLow: const Color(0xFFF4EEE1),
      surfaceContainerHighest: brume,
      outlineVariant: const Color(0xFFD8CFBA),
      primaryContainer: const Color(0xFFE4E0D2),
      onPrimaryContainer: nuit,
      tertiaryContainer: const Color(0xFFEFE6CE),
      onTertiaryContainer: const Color(0xFF6B5510),
      error: carmin,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: encre,
      brightness: Brightness.dark,
    ).copyWith(
      primary: ivoire,
      onPrimary: nuit,
      secondary: or,
      surface: const Color(0xFF0E1326),
      onSurface: ivoire,
      surfaceContainerLow: const Color(0xFF171E38),
      surfaceContainerHighest: const Color(0xFF232B4A),
      outlineVariant: const Color(0xFF313A5C),
      primaryContainer: const Color(0xFF232B4A),
      onPrimaryContainer: ivoire,
      tertiaryContainer: const Color(0xFF2E2A16),
      onTertiaryContainer: const Color(0xFFE3C86C),
      error: const Color(0xFFD06A63),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 24,
          fontFamily: displayFont,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          )
          .copyWith(
            displayLarge: TextStyle(
                fontFamily: displayFont,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface),
            displayMedium: TextStyle(
                fontFamily: displayFont,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface),
            headlineMedium: TextStyle(
                fontFamily: displayFont,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface),
            titleLarge: TextStyle(
                fontFamily: displayFont,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface),
          ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: isDark ? or : encre,
          foregroundColor: isDark ? nuit : ivoire,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant, width: 0.8),
        backgroundColor: scheme.surface,
        selectedColor: isDark ? const Color(0xFF3A3417) : const Color(0xFFEFE6CE),
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 13),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 0.8),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? const Color(0xFF3A3417) : const Color(0xFFEFE6CE),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
            fontSize: 12,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface)),
      ),
    );
  }
}

/// Petit intitulé de section « à la française » : capitales espacées, filet or.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 0.8, color: AppTheme.or.withValues(alpha: 0.5))),
      ],
    );
  }
}
