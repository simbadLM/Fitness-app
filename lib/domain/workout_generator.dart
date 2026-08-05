import 'dart:math';

import 'content.dart';
import 'gamification.dart';
import 'models.dart';

/// Génère la "quête du jour" selon la méthode du guide :
/// 1 exercice par groupe musculaire (dans sa phase courante) + 1–2 exercices
/// sur le groupe focus du jour, filtrés selon le matériel possédé.
abstract final class WorkoutGenerator {
  /// Rotation du focus selon le guide (lun bras/pecs, mar jambes, jeu abdos,
  /// ven dos ; mer/sam/dim : circuit sans focus).
  static const Map<int, String?> focusByWeekday = {
    DateTime.monday: 'armsChest',
    DateTime.tuesday: 'legs',
    DateTime.wednesday: null,
    DateTime.thursday: 'abs',
    DateTime.friday: 'back',
    DateTime.saturday: null,
    DateTime.sunday: null,
  };

  static const Set<Equipment> weightEquipment = {
    Equipment.kettlebell,
    Equipment.backpack,
    Equipment.weightVest,
  };

  static WorkoutPlan generate({
    required Program program,
    required Map<String, GroupProgress> progress,
    required Set<Equipment> owned,
    required DateTime date,

    /// exerciseId → répétitions de la dernière série enregistrée.
    Map<String, int> lastSetReps = const {},
  }) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final focusGroupId = focusByWeekday[date.weekday];
    final movements = <Movement>[];
    String? bossGroupId;

    for (final (index, group) in program.groups.indexed) {
      final groupProgress = progress[group.id] ?? GroupProgress(groupId: group.id);
      final phase = groupProgress.phase;
      final pool = _availablePool(group, phase, owned);
      final random = Random(seed + index);
      final exercise = pool[random.nextInt(pool.length)];
      final weighted = phase >= 4 && owned.any(weightEquipment.contains);

      final isBoss = bossGroupId == null &&
          groupProgress.bossStatus == BossStatus.ready;
      final target =
          isBoss ? Gamification.bossTarget(lastSetReps[exercise.id]) : null;
      if (isBoss) bossGroupId = group.id;

      movements.add(Movement(
        group: group,
        exercise: exercise,
        phase: phase,
        weighted: weighted,
        isBoss: isBoss,
        bossTarget: target,
        suggestedReps: lastSetReps[exercise.id] ??
            (exercise.type == ExerciseType.duration ? 30 : 10),
      ));

      if (group.id == focusGroupId) {
        final others = pool.where((e) => e.id != exercise.id).toList();
        if (others.isNotEmpty) {
          final extra = others[random.nextInt(others.length)];
          movements.add(Movement(
            group: group,
            exercise: extra,
            phase: phase,
            weighted: weighted,
            isFocus: true,
            suggestedReps: lastSetReps[extra.id] ??
                (extra.type == ExerciseType.duration ? 30 : 10),
          ));
        }
      }
    }

    return WorkoutPlan(
      movements: movements,
      focusGroupId: focusGroupId,
      bossGroupId: bossGroupId,
      duration: program.method.sessionDuration,
    );
  }

  /// Alternatives du même groupe/phase pour remplacer un mouvement proposé.
  static List<Exercise> alternatives({
    required Movement movement,
    required Set<Equipment> owned,
  }) =>
      _availablePool(movement.group, movement.phase, owned)
          .where((e) => e.id != movement.exercise.id)
          .toList();

  /// Exercices de la phase filtrés par matériel ; si le filtre vide le pool
  /// (profil sans aucun matériel sur une phase très équipée), on retombe sur
  /// la liste complète plutôt que de bloquer la séance.
  static List<Exercise> _availablePool(
      MuscleGroup group, int phase, Set<Equipment> owned) {
    final all = group.exercisesForPhase(phase);
    final filtered = [
      for (final e in all)
        if (e.availableWith(owned)) e,
    ];
    return filtered.isEmpty ? all : filtered;
  }
}
