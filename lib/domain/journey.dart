import 'models.dart';

/// Le voyage 365 : devenir fit en 365 jours d'entraînement de 20 minutes.
abstract final class Journey {
  static const int totalDays = 365;

  /// L'arc narratif des phases.
  static const Map<int, String> arcNames = {
    1: 'Apprentissage · Reprise',
    2: 'Consolidation',
    3: 'Athlétisation',
    4: 'Maîtrise',
  };

  static const Map<int, String> arcMottos = {
    1: 'On apprend les gestes, on retrouve son corps.',
    2: 'L\'habitude s\'installe, la forme revient.',
    3: 'Le corps devient athlète.',
    4: 'La force se raffine sous la charge.',
  };

  /// Arc courant : la moyenne des phases des groupes, arrondie vers le bas —
  /// on n'entre dans l'arc suivant que quand l'ensemble du corps y est.
  static int currentArc(Iterable<GroupProgress> progress) {
    if (progress.isEmpty) return 1;
    final avg = progress.map((p) => p.phase).reduce((a, b) => a + b) /
        progress.length;
    return avg.floor().clamp(1, 4);
  }

  /// Timeline projetée : les arcs restants (à partir de [startArc]) se
  /// partagent équitablement les 365 jours. Projection indicative, recalculée
  /// à mesure que les phases réelles évoluent.
  static List<({int arc, String name, int startDay, int endDay})> segments(
      int startArc) {
    final arcs = [for (var a = startArc.clamp(1, 4); a <= 4; a++) a];
    final share = totalDays / arcs.length;
    return [
      for (final (i, a) in arcs.indexed)
        (
          arc: a,
          name: arcNames[a]!,
          startDay: (i * share).round(),
          endDay: ((i + 1) * share).round(),
        ),
    ];
  }
}
