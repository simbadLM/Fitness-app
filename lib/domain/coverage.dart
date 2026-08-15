import 'content.dart';
import 'models.dart';

/// Couverture des schémas moteurs sur une fenêtre glissante (7 jours).
abstract final class Coverage {
  /// Schéma moteur → nombre de jours (distincts) où il a été travaillé,
  /// à partir des jours de pratique par exercice.
  static Map<MovementPattern, int> patternDayCounts(
    Map<String, Set<DateTime>> usageDays,
    Program program,
  ) {
    final patternsByDay = <DateTime, Set<MovementPattern>>{};
    for (final entry in usageDays.entries) {
      final exercise = program.findExercise(entry.key);
      if (exercise == null) continue;
      for (final day in entry.value) {
        patternsByDay.putIfAbsent(day, () => {}).addAll(exercise.patterns);
      }
    }
    final counts = <MovementPattern, int>{};
    for (final patterns in patternsByDay.values) {
      for (final p in patterns) {
        counts[p] = (counts[p] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Schémas atteignables par l'utilisateur : union des patterns des pools
  /// de phase courante de chaque groupe, filtrés par matériel possédé.
  static Set<MovementPattern> accessiblePatterns({
    required Program program,
    required Map<String, GroupProgress> progress,
    required Set<Equipment> owned,
  }) {
    final result = <MovementPattern>{};
    for (final group in program.groups) {
      final phase = progress[group.id]?.phase ?? 1;
      for (final e in group.exercisesForPhase(phase)) {
        if (e.availableWith(owned)) result.addAll(e.patterns);
      }
    }
    return result;
  }
}
