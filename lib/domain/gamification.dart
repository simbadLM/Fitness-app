import 'dart:math';

import 'models.dart';

/// Moteur de gamification — fonctions pures, testées unitairement.
abstract final class Gamification {
  static const int completionBonus = 50;
  static const int bossBonus = 200;

  /// 1 XP par répétition ; pour les exercices chronométrés, 1 XP par 5 s.
  static int xpForSet(SetLog set) =>
      set.isDuration ? max(1, set.reps ~/ 5) : set.reps;

  static int xpFromSets(Iterable<SetLog> sets) =>
      sets.fold(0, (sum, s) => sum + xpForSet(s));

  /// Bonus de régularité : +5 XP par jour de streak, plafonné à +100.
  static int streakBonus(int streak) => min(streak * 5, 100);

  /// Coût en XP pour passer du niveau [level] au suivant.
  static int xpCostForLevel(int level) => 200 + 100 * (level - 1);

  /// (niveau courant, XP dans le niveau, XP nécessaires pour le suivant).
  static ({int level, int inLevel, int forNext}) levelInfo(int xp) {
    var level = 1;
    var remaining = xp;
    while (remaining >= xpCostForLevel(level)) {
      remaining -= xpCostForLevel(level);
      level++;
    }
    return (level: level, inLevel: remaining, forNext: xpCostForLevel(level));
  }

  /// Jour d'entraînement planifié le plus récent strictement avant [day].
  /// [trainingDays] vide = tous les jours sont planifiés.
  static DateTime previousScheduledDay(DateTime day, Set<int> trainingDays) {
    final d = DateTime(day.year, day.month, day.day);
    for (var i = 1; i <= 7; i++) {
      final candidate = d.subtract(Duration(days: i));
      if (trainingDays.isEmpty || trainingDays.contains(candidate.weekday)) {
        return candidate;
      }
    }
    return d.subtract(const Duration(days: 1));
  }

  /// Streak après une séance effectuée le jour [today].
  /// Les jours de repos planifiés ne cassent pas la série.
  static int streakAfterSession({
    required int current,
    required DateTime? lastTrainingDay,
    required DateTime today,
    required Set<int> trainingDays,
  }) {
    final t = DateTime(today.year, today.month, today.day);
    if (lastTrainingDay != null) {
      final last = DateTime(
          lastTrainingDay.year, lastTrainingDay.month, lastTrainingDay.day);
      if (last == t) return max(current, 1);
      final previousScheduled = previousScheduledDay(t, trainingDays);
      if (!last.isBefore(previousScheduled)) return current + 1;
    }
    return 1;
  }

  /// Streak affiché aujourd'hui (0 si la série est cassée).
  static int currentStreak({
    required int stored,
    required DateTime? lastTrainingDay,
    required DateTime today,
    required Set<int> trainingDays,
  }) {
    if (lastTrainingDay == null) return 0;
    final t = DateTime(today.year, today.month, today.day);
    final last = DateTime(
        lastTrainingDay.year, lastTrainingDay.month, lastTrainingDay.day);
    if (last == t) return stored;
    final previousScheduled = previousScheduledDay(t, trainingDays);
    return last.isBefore(previousScheduled) ? 0 : stored;
  }

  // --- Modèle AMRAP à objectifs fixes ---

  /// Incrément de micro-progression (rule of thumb du guide : +2 reps).
  static const int targetIncrementReps = 2;
  static const int targetIncrementSeconds = 10;

  /// Seuil de maîtrise d'un objectif : au-delà, on ne relève plus l'objectif,
  /// on déclenche le boss fight vers la phase supérieure (« move to the next
  /// phase when movements are too easy »).
  static const int masteryReps = 15;
  static const int masterySeconds = 60;

  static int targetIncrement(bool isDuration) =>
      isDuration ? targetIncrementSeconds : targetIncrementReps;

  static bool isMastered({required int target, required bool isDuration}) =>
      target >= (isDuration ? masterySeconds : masteryReps);

  /// Objectif initial déduit de la calibration : pendant la première pratique
  /// d'un exercice, l'utilisateur fait ce qu'il tient sur chaque tour et
  /// saisit ses répétitions réelles. L'objectif retenu est la **médiane** de
  /// ces séries — le rythme effectivement tenable en circuit (pas un max).
  static int calibrationTargetFromSets(List<int> reps,
      {required bool isDuration}) {
    final floor = isDuration ? 15 : 5;
    if (reps.isEmpty) return floor;
    final sorted = [...reps]..sort();
    final n = sorted.length;
    final median = n.isOdd
        ? sorted[n ~/ 2]
        : ((sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2).round();
    return max(floor, median);
  }

  /// Un groupe réussit sa séance si chaque série de ses mouvements à objectif
  /// atteint l'objectif (aucune série en dessous, au moins une série faite).
  static bool groupSucceeded({
    required Iterable<SetLog> sets,
    required Map<String, int> targetByExercise,
  }) {
    var any = false;
    for (final s in sets) {
      final target = targetByExercise[s.exerciseId];
      if (target == null) continue;
      any = true;
      if (s.reps < target) return false;
    }
    return any;
  }

  /// Compteur de séances réussies consécutives d'un groupe.
  static int nextSuccessStreak({required int current, required bool succeeded}) =>
      succeeded ? current + 1 : 0;

  /// Le boss est vaincu si toutes les séries du mouvement boss tiennent
  /// l'objectif relevé, sur au moins un tour.
  static bool bossDefeated({
    required Iterable<SetLog> bossSets,
    required int target,
  }) =>
      bossSets.isNotEmpty && bossSets.every((s) => s.reps >= target);
}

/// Un badge à débloquer. Les conditions sont évaluées sur un instantané des
/// statistiques après chaque séance.
class Badge {
  const Badge(this.id, this.title, this.description, this.condition);

  final String id;
  final String title;
  final String description;
  final bool Function(BadgeStats stats) condition;

  static const _all = <Badge>[];

  static List<Badge> get all => _all.isEmpty ? _badges : _all;
}

class BadgeStats {
  const BadgeStats({
    required this.totalSessions,
    required this.totalReps,
    required this.streak,
    required this.bestRounds,
    required this.bossWins,
    required this.phases,
  });

  final int totalSessions;
  final int totalReps;
  final int streak;
  final int bestRounds;
  final int bossWins;

  /// groupId → phase courante.
  final Map<String, int> phases;
}

final List<Badge> _badges = [
  Badge('first_session', 'Première quête',
      'Terminer sa première séance.', (s) => s.totalSessions >= 1),
  Badge('sessions_10', 'Habitué',
      'Terminer 10 séances.', (s) => s.totalSessions >= 10),
  Badge('sessions_50', 'Machine',
      'Terminer 50 séances.', (s) => s.totalSessions >= 50),
  Badge('sessions_100', 'Centurion',
      'Terminer 100 séances.', (s) => s.totalSessions >= 100),
  Badge('streak_7', 'Semaine de feu',
      '7 jours de série.', (s) => s.streak >= 7),
  Badge('streak_30', 'Mois de fer',
      '30 jours de série.', (s) => s.streak >= 30),
  Badge('boss_first', 'Tombeur de boss',
      'Vaincre son premier boss et débloquer une phase.', (s) => s.bossWins >= 1),
  Badge('rounds_8', 'Tornade',
      '8 tours de circuit dans une même séance.', (s) => s.bestRounds >= 8),
  Badge('reps_1000', 'Millier',
      '1 000 répétitions au total.', (s) => s.totalReps >= 1000),
  Badge('reps_10000', 'Dix mille',
      '10 000 répétitions au total.', (s) => s.totalReps >= 10000),
  Badge('phase3_any', 'Vétéran',
      'Atteindre la phase Advanced dans un groupe.',
      (s) => s.phases.values.any((p) => p >= 3)),
  Badge('phase4_any', 'Pro',
      'Atteindre la phase Pro dans un groupe.',
      (s) => s.phases.values.any((p) => p >= 4)),
  Badge('phase4_all', 'Légende',
      'Atteindre la phase Pro dans les 4 groupes.',
      (s) => s.phases.isNotEmpty && s.phases.values.every((p) => p >= 4)),
];

/// Badges nouvellement débloqués par rapport à [alreadyUnlocked].
List<Badge> newlyUnlockedBadges(BadgeStats stats, Set<String> alreadyUnlocked) =>
    [
      for (final b in Badge.all)
        if (!alreadyUnlocked.contains(b.id) && b.condition(stats)) b,
    ];
