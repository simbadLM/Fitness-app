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

  /// Rule of thumb du guide : +2 reps ou plus sur la dernière série du même
  /// exercice par rapport à la séance précédente.
  static bool isImprovement({
    required int lastSetReps,
    required int previousLastSetReps,
  }) =>
      lastSetReps >= previousLastSetReps + 2;

  /// Met à jour le compteur d'améliorations consécutives d'un groupe après une
  /// séance normale. `null` en entrée = pas d'historique comparable (inchangé).
  static int nextImprovementStreak({
    required int current,
    required int? lastSetReps,
    required int? previousLastSetReps,
  }) {
    if (lastSetReps == null || previousLastSetReps == null) return current;
    return isImprovement(
            lastSetReps: lastSetReps, previousLastSetReps: previousLastSetReps)
        ? current + 1
        : 0;
  }

  /// Objectif du boss fight : battre sa dernière série de 2 répétitions.
  static int bossTarget(int? previousLastSetReps) =>
      (previousLastSetReps ?? 8) + 2;

  static bool bossDefeated({
    required Iterable<SetLog> bossSets,
    required int target,
  }) =>
      bossSets.any((s) => s.reps >= target);
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
