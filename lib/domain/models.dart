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
    this.levelInPhase = 1,
  });

  final String groupId;
  final int phase;

  /// Niveau au sein de la phase : +1 à chaque relèvement d'objectifs.
  final int levelInPhase;

  /// Séances consécutives où tous les objectifs du groupe ont été tenus.
  /// 0 = normal, 1 = boss en approche, >= 2 = boss fight prêt (le compteur
  /// n'atteint 2 que si les objectifs sont au seuil de maîtrise ; sinon ils
  /// sont relevés de +2 et le compteur repart à 0 — micro-progression).
  final int improvementStreak;

  GroupProgress copyWith(
          {int? phase, int? improvementStreak, int? levelInPhase}) =>
      GroupProgress(
        groupId: groupId,
        phase: phase ?? this.phase,
        improvementStreak: improvementStreak ?? this.improvementStreak,
        levelInPhase: levelInPhase ?? this.levelInPhase,
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
///
/// Modèle AMRAP à volume fixe : chaque mouvement porte un objectif de
/// répétitions ([target]) identique à chaque tour ; le score de la séance est
/// le nombre de tours. Un mouvement sans objectif connu est en
/// [isCalibration] : l'utilisateur saisit ses répétitions réelles et
/// l'objectif en est déduit en fin de séance.
class Movement {
  const Movement({
    required this.group,
    required this.exercise,
    required this.phase,
    this.target,
    this.weighted = false,
    this.isFocus = false,
    this.isBoss = false,
  });

  final MuscleGroup group;
  final Exercise exercise;
  final int phase;

  /// Objectif fixe par tour (reps, ou secondes pour un exercice chronométré).
  /// `null` = calibration.
  final int? target;

  final bool weighted;
  final bool isFocus;
  final bool isBoss;

  bool get isCalibration => target == null;

  /// Objectif affiché : celui du boss (+2) si le mouvement est un boss.
  int? get effectiveTarget =>
      isBoss && target != null ? target! + 2 : target;

  Movement copyWith({Exercise? exercise, int? Function()? target}) => Movement(
        group: group,
        exercise: exercise ?? this.exercise,
        phase: phase,
        target: target != null ? target() : this.target,
        weighted: weighted,
        isFocus: isFocus,
        isBoss: isBoss,
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
    this.targetUps = const {},
    this.calibratedTargets = const {},
    required this.playerLevelBefore,
    required this.playerLevelAfter,
    this.dayNumber = 1,
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

  /// exerciseId → (ancien objectif, nouvel objectif) relevé après maîtrise.
  final Map<String, ({int from, int to})> targetUps;

  /// exerciseId → objectif fixé par la calibration de cette séance.
  final Map<String, int> calibratedTargets;

  final int playerLevelBefore;
  final int playerLevelAfter;

  /// Numéro du jour d'entraînement dans le voyage (1 → 365), après la séance.
  final int dayNumber;
}
