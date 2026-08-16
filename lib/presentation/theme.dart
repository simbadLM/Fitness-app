import 'package:flutter/material.dart';

import 'palettes.dart';

/// Direction artistique sport / gaming : fond bleu nuit, gradient signature
/// (coloris au choix parmi les palettes fixes), typo athlétique Rajdhani.
abstract final class AppTheme {
  static const nuit = Color(0xFF0B1120);
  static const surfaceSombre = Color(0xFF131C31);
  static const blanc = Color(0xFFEAF2F8);

  /// Couleurs fixes, indépendantes du coloris choisi.
  static const carmin = Color(0xFFFF4D5E); // boss
  static const boss = carmin;
  static const flamme = Color(0xFFFF8A3D); // streak
  static const trophee = Color(0xFFF2B705); // badges

  /// Titres et grands chiffres.
  static const displayFont = 'Rajdhani';

  static Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static ThemeData light(AppPalette palette) {
    final accent = _darken(palette.b, 0.10);
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.b,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      secondary: _darken(palette.a, 0.12),
      surface: const Color(0xFFF4F8FC),
      onSurface: const Color(0xFF10192E),
      surfaceContainerLow: Colors.white,
      surfaceContainerHighest: const Color(0xFFDDE7F0),
      outlineVariant: const Color(0xFFC9D6E2),
      primaryContainer:
          Color.alphaBlend(palette.a.withValues(alpha: 0.20), Colors.white),
      onPrimaryContainer: _darken(palette.b, 0.25),
      tertiaryContainer: const Color(0xFFD9EEFB),
      onTertiaryContainer: const Color(0xFF14425E),
      error: const Color(0xFFD03A49),
    );
    return _base(scheme, palette);
  }

  static ThemeData dark(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.b,
      brightness: Brightness.dark,
    ).copyWith(
      primary: palette.a,
      onPrimary: nuit,
      secondary: palette.b,
      surface: nuit,
      onSurface: blanc,
      surfaceContainerLow: surfaceSombre,
      surfaceContainerHighest: const Color(0xFF1E2A45),
      outlineVariant: const Color(0xFF27324E),
      primaryContainer:
          Color.alphaBlend(palette.a.withValues(alpha: 0.20), surfaceSombre),
      onPrimaryContainer: palette.a,
      tertiaryContainer: const Color(0xFF14304A),
      onTertiaryContainer: const Color(0xFF7CD2F5),
      error: carmin,
    );
    return _base(scheme, palette);
  }

  static ThemeData _base(ColorScheme scheme, AppPalette palette) {
    final isDark = scheme.brightness == Brightness.dark;
    final selected =
        Color.alphaBlend(palette.a.withValues(alpha: isDark ? 0.22 : 0.20),
            isDark ? surfaceSombre : Colors.white);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [AppColors.of(palette)],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 26,
          fontFamily: displayFont,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
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
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: isDark ? palette.a : _darken(palette.b, 0.10),
          foregroundColor: isDark ? nuit : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: displayFont,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant, width: 0.8),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: selected,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 13),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 0.8),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: selected,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
            fontSize: 12,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface)),
      ),
    );
  }
}

/// Intitulé de section : capitales espacées + filet dégradé.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 14,
            letterSpacing: 2.6,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                colors.accent.withValues(alpha: 0.7),
                colors.accentB.withValues(alpha: 0.0),
              ]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}
