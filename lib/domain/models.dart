import 'dart:convert';

import 'content.dart';

enum Sex { male, female }

class Profile {
  const Profile({
    required this.name,
    required this.sex,
    this.equipment = const {},
    this.trainingDays = const {1, 2, 4, 5, 6},
  });

  final String name;
  final Sex sex;
  final Set<Equipment> equipment;

  /// Jours d'entraînement planifiés ([DateTime.weekday] : 1 = lundi … 7 = dimanche).
  /// Défaut du guide : lun–ven sauf mercredi, + samedi ; repos mercredi et dimanche.
  final Set<int> trainingDays;

  Profile copyWith({
    String? name,
    Sex? sex,
    Set<Equipment>? equipment,
    Set<int>? trainingDays,
  }) =>
      Profile(
        name: name ?? this.name,
        sex: sex ?? this.sex,
        equipment: equipment ?? this.equipment,
        trainingDays: trainingDays ?? this.trainingDays,
      );

  String toJsonString() => jsonEncode({
        'name': name,
        'sex': sex.name,
        'equipment': [for (final e in equipment) e.name],
        'trainingDays': trainingDays.toList(),
      });

  static Profile fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return Profile(
      name: json['name'] as String,
      sex: Sex.values.byName(json['sex'] as String),
      equipment: {
        for (final e in (json['equipment'] as List))
          Equipment.values.byName(e as String),
      },
      trainingDays: {for (final d in (json['trainingDays'] as List)) d as int},
    );
  }
}

/// Progression d'un groupe musculaire.
class GroupProgress {
  const GroupProgress({
    required this.groupId,
    this.phase = 1,
    this.improvementStreak = 0,
  });

  final String groupId;
  final int phase;

  /// Nombre de séances consécutives avec amélioration (+2 reps sur la dernière
  /// série du même exercice). 0 = normal, 1 = boss approche, >= 2 = boss fight.
  final int improvementStreak;

  GroupProgress copyWith({int? phase, int? improvementStreak}) => GroupProgress(
        groupId: groupId,
        phase: phase ?? this.phase,
        improvementStreak: improvementStreak ?? this.improvementStreak,
      );
}

enum BossStatus { normal, approaching, ready }

extension GroupProgressBoss on GroupProgress {
  BossStatus get bossStatus {
    if (phase >= MuscleGroup.maxPhase) return BossStatus.normal;
    if (improvementStreak >= 2) return BossStatus.ready;
    if (improvementStreak == 1) return BossStatus.approaching;
    return BossStatus.normal;
  }
}

/// Une série effectuée pendant une séance.
/// Pour un exercice [ExerciseType.duration], [reps] contient des secondes.
class SetLog {
  const SetLog({
    required this.exerciseId,
    required this.groupId,
    required this.phase,
    required this.round,
    required this.reps,
    this.weighted = false,
    this.isDuration = false,
  });

  final String exerciseId;
  final String groupId;
  final int phase;
  final int round;
  final int reps;
  final bool weighted;
  final bool isDuration;
}

/// Un mouvement du circuit du jour.
class Movement {
  const Movement({
    required this.group,
    required this.exercise,
    required this.phase,
    this.weighted = false,
    this.isFocus = false,
    this.isBoss = false,
    this.bossTarget,
    this.suggestedReps,
  });

  final MuscleGroup group;
  final Exercise exercise;
  final int phase;
  final bool weighted;
  final bool isFocus;
  final bool isBoss;

  /// Répétitions à atteindre sur une série pour vaincre le boss.
  final int? bossTarget;

  /// Pré-remplissage du compteur (dernière perf connue ou défaut).
  final int? suggestedReps;

  Movement copyWith({Exercise? exercise, bool? isBoss, int? bossTarget}) =>
      Movement(
        group: group,
        exercise: exercise ?? this.exercise,
        phase: phase,
        weighted: weighted,
        isFocus: isFocus,
        isBoss: isBoss ?? this.isBoss,
        bossTarget: bossTarget ?? this.bossTarget,
        suggestedReps: suggestedReps,
      );
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.movements,
    this.focusGroupId,
    this.bossGroupId,
    this.duration = const Duration(minutes: 20),
  });

  final List<Movement> movements;
  final String? focusGroupId;
  final String? bossGroupId;
  final Duration duration;
}

/// Résultat d'une séance sauvegardée — affiché sur l'écran de récompense.
class SessionResult {
  const SessionResult({
    required this.xpTotal,
    required this.xpFromReps,
    required this.xpCompletionBonus,
    required this.xpStreakBonus,
    required this.xpBossBonus,
    required this.totalReps,
    required this.rounds,
    required this.duration,
    required this.streak,
    required this.newBadges,
    this.bossGroupId,
    this.bossWon = false,
    this.phaseUps = const {},
    required this.playerLevelBefore,
    required this.playerLevelAfter,
  });

  final int xpTotal;
  final int xpFromReps;
  final int xpCompletionBonus;
  final int xpStreakBonus;
  final int xpBossBonus;
  final int totalReps;
  final int rounds;
  final Duration duration;
  final int streak;
  final List<String> newBadges;
  final String? bossGroupId;
  final bool bossWon;

  /// groupId → nouvelle phase débloquée pendant cette séance.
  final Map<String, int> phaseUps;
  final int playerLevelBefore;
  final int playerLevelAfter;
}
