import 'package:flutter/material.dart';

/// Coloris proposés : chaque palette fixe le duo du gradient signature.
/// Le reste du thème (fonds, cartes, textes) est commun.
enum AppPalette {
  turquoise('Turquoise électrique', Color(0xFF22E7C7), Color(0xFF3B82F6)),
  volcan('Volcan', Color(0xFFFF8A3D), Color(0xFFE5484D)),
  ultraviolet('Ultraviolet', Color(0xFFA78BFA), Color(0xFF6366F1)),
  emeraude('Émeraude', Color(0xFF34D399), Color(0xFF059669)),
  royal('Or royal', Color(0xFFF5C044), Color(0xFFD97706)),
  neon('Rose néon', Color(0xFFF472B6), Color(0xFF8B5CF6));

  const AppPalette(this.labelFr, this.a, this.b);

  final String labelFr;

  /// Début du gradient (accent principal).
  final Color a;

  /// Fin du gradient.
  final Color b;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [a, b],
      );
}

/// Couleurs dynamiques du thème, résolues via `context.colors`.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.accentB,
    required this.gradient,
    required this.boss,
    required this.bossGradient,
  });

  final Color accent;
  final Color accentB;
  final LinearGradient gradient;
  final Color boss;
  final LinearGradient bossGradient;

  factory AppColors.of(AppPalette palette) => AppColors(
        accent: palette.a,
        accentB: palette.b,
        gradient: palette.gradient,
        boss: const Color(0xFFFF4D5E),
        bossGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B5E), Color(0xFFC62861)],
        ),
      );

  @override
  AppColors copyWith({
    Color? accent,
    Color? accentB,
    LinearGradient? gradient,
    Color? boss,
    LinearGradient? bossGradient,
  }) =>
      AppColors(
        accent: accent ?? this.accent,
        accentB: accentB ?? this.accentB,
        gradient: gradient ?? this.gradient,
        boss: boss ?? this.boss,
        bossGradient: bossGradient ?? this.bossGradient,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentB: Color.lerp(accentB, other.accentB, t)!,
      gradient: LinearGradient.lerp(gradient, other.gradient, t)!,
      boss: Color.lerp(boss, other.boss, t)!,
      bossGradient: LinearGradient.lerp(bossGradient, other.bossGradient, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
