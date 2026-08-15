import 'content.dart';
import 'models.dart';

/// Génère la « quête du jour » : 1 exercice par groupe musculaire (dans sa
/// phase courante) + 1 exercice focus, filtrés selon le matériel possédé.
///
/// Le choix des exercices est **conscient de la couverture** : à pool égal,
/// on privilégie d'abord l'exercice qui travaille les schémas moteurs les
/// moins couverts sur les 7 derniers jours, puis le moins récemment pratiqué.
/// Sur une semaine, le pool de chaque phase tourne entièrement et tous les
/// schémas accessibles sont visités — sans hasard, de façon testable.
abstract final class WorkoutGenerator {
  /// Rotation du focus (lun bras/pecs, mar jambes, jeu abdos, ven dos).
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

    /// exerciseId → objectif fixe par tour (absent = calibration).
    Map<String, int> targets = const {},

    /// exerciseId → date de dernière pratique.
    Map<String, DateTime> lastUsed = const {},

    /// Schéma moteur → nombre de jours où il a été travaillé (7 derniers jours).
    Map<MovementPattern, int> recentPatternCounts = const {},
  }) {
    final focusGroupId = focusByWeekday[date.weekday];
    final movements = <Movement>[];
    String? bossGroupId;

    for (final group in program.groups) {
      final groupProgress = progress[group.id] ?? GroupProgress(groupId: group.id);
      final phase = groupProgress.phase;
      final pool = _availablePool(group, phase, owned);
      final weighted = phase >= 4 && owned.any(weightEquipment.contains);

      // Boss : exercice de référence = le plus difficile (tier max) parmi les
      // exercices déjà calibrés du pool — pas question de valider une phase
      // sur son exercice le plus facile.
      final calibratedPool = [
        for (final e in pool)
          if (targets.containsKey(e.id)) e,
      ];
      final wantsBoss = bossGroupId == null &&
          groupProgress.bossStatus == BossStatus.ready &&
          calibratedPool.isNotEmpty;

      final Exercise exercise;
      if (wantsBoss) {
        calibratedPool.sort((a, b) {
          final byTier = b.tier.compareTo(a.tier);
          return byTier != 0 ? byTier : a.id.compareTo(b.id);
        });
        exercise = calibratedPool.first;
        bossGroupId = group.id;
      } else {
        exercise = _pickForCoverage(pool,
            date: date,
            lastUsed: lastUsed,
            recentPatternCounts: recentPatternCounts);
      }

      movements.add(Movement(
        group: group,
        exercise: exercise,
        phase: phase,
        target: targets[exercise.id],
        weighted: weighted,
        isBoss: wantsBoss,
      ));

      if (group.id == focusGroupId) {
        final others = pool.where((e) => e.id != exercise.id).toList();
        if (others.isNotEmpty) {
          final extra = _pickForCoverage(others,
              date: date,
              lastUsed: lastUsed,
              recentPatternCounts: recentPatternCounts);
          movements.add(Movement(
            group: group,
            exercise: extra,
            phase: phase,
            target: targets[extra.id],
            weighted: weighted,
            isFocus: true,
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

  /// Meilleur candidat pour la couverture. Ordre lexicographique déterministe :
  /// 1. nombre de schémas moteurs **pas encore couverts** cette semaine
  ///    (l'exercice qui débloque le plus de cases gagne),
  /// 2. ancienneté de dernière pratique (jamais pratiqué = prioritaire) —
  ///    une fois tout couvert, c'est une rotation LRU pure du pool,
  /// 3. identifiant (stabilité du choix pour une même journée).
  static Exercise _pickForCoverage(
    List<Exercise> pool, {
    required DateTime date,
    required Map<String, DateTime> lastUsed,
    required Map<MovementPattern, int> recentPatternCounts,
  }) {
    int uncovered(Exercise e) => e.patterns
        .where((p) => (recentPatternCounts[p] ?? 0) == 0)
        .length;

    int staleness(Exercise e) {
      final last = lastUsed[e.id];
      if (last == null) return 100000;
      return date.difference(last).inDays.clamp(0, 3650);
    }

    final sorted = [...pool]..sort((a, b) {
        final byUncovered = uncovered(b).compareTo(uncovered(a));
        if (byUncovered != 0) return byUncovered;
        final byStaleness = staleness(b).compareTo(staleness(a));
        if (byStaleness != 0) return byStaleness;
        return a.id.compareTo(b.id);
      });
    return sorted.first;
  }

  /// Alternatives du même groupe/phase pour remplacer un mouvement proposé.
  static List<Exercise> alternatives({
    required Movement movement,
    required Set<Equipment> owned,
  }) =>
      _availablePool(movement.group, movement.phase, owned)
          .where((e) => e.id != movement.exercise.id)
          .toList();

  /// Exercices de la phase filtrés par matériel ; si le filtre vide le pool,
  /// on retombe sur la liste complète plutôt que de bloquer la séance.
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
