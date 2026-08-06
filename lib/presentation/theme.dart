import 'package:flutter/material.dart';

/// Direction artistique sport / gaming : fond bleu nuit, gradient
/// turquoise → bleu électrique, typo athlétique Rajdhani.
abstract final class AppTheme {
  static const nuit = Color(0xFF0B1120); // fond sombre
  static const surfaceSombre = Color(0xFF131C31);
  static const turquoise = Color(0xFF22E7C7);
  static const bleu = Color(0xFF3B82F6);
  static const blanc = Color(0xFFEAF2F8);
  static const carmin = Color(0xFFFF4D5E); // boss
  static const flamme = Color(0xFFFF8A3D);

  /// Alias historiques (props des pictogrammes, accents).
  static const or = turquoise;
  static const gold = turquoise;
  static const boss = carmin;
  static const ivoire = blanc;

  /// Le gradient signature de l'app.
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [turquoise, bleu],
  );

  static const bossGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B5E), Color(0xFFC62861)],
  );

  /// Titres et grands chiffres.
  static const displayFont = 'Rajdhani';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: bleu,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF0E8DBF),
      secondary: const Color(0xFF0AA88E),
      surface: const Color(0xFFF4F8FC),
      onSurface: const Color(0xFF10192E),
      surfaceContainerLow: Colors.white,
      surfaceContainerHighest: const Color(0xFFDDE7F0),
      outlineVariant: const Color(0xFFC9D6E2),
      primaryContainer: const Color(0xFFD3F5EE),
      onPrimaryContainer: const Color(0xFF0A4A40),
      tertiaryContainer: const Color(0xFFD9EEFB),
      onTertiaryContainer: const Color(0xFF14425E),
      error: const Color(0xFFD03A49),
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: bleu,
      brightness: Brightness.dark,
    ).copyWith(
      primary: turquoise,
      onPrimary: nuit,
      secondary: bleu,
      surface: nuit,
      onSurface: blanc,
      surfaceContainerLow: surfaceSombre,
      surfaceContainerHighest: const Color(0xFF1E2A45),
      outlineVariant: const Color(0xFF27324E),
      primaryContainer: const Color(0xFF123B41),
      onPrimaryContainer: turquoise,
      tertiaryContainer: const Color(0xFF14304A),
      onTertiaryContainer: const Color(0xFF7CD2F5),
      error: carmin,
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
          backgroundColor: isDark ? turquoise : const Color(0xFF0E8DBF),
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
        selectedColor: isDark ? const Color(0xFF123B41) : const Color(0xFFD3F5EE),
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 13),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 0.8),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? const Color(0xFF123B41) : const Color(0xFFD3F5EE),
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
                AppTheme.turquoise.withValues(alpha: 0.7),
                AppTheme.bleu.withValues(alpha: 0.0),
              ]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}
