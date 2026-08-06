import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/content.dart';
import '../domain/gamification.dart';
import '../domain/models.dart';
import 'db.dart';

class ContentRepository {
  static Future<Program> load() async =>
      Program.fromJsonString(await rootBundle.loadString('content/program.json'));
}

class ProfileRepository {
  ProfileRepository(this._prefs);

  static const _key = 'profile';
  final SharedPreferences _prefs;

  Profile? load() {
    final raw = _prefs.getString(_key);
    return raw == null ? null : Profile.fromJsonString(raw);
  }

  Future<void> save(Profile profile) =>
      _prefs.setString(_key, profile.toJsonString());
}

class PlayerSnapshot {
  const PlayerSnapshot({
    required this.xp,
    required this.streak,
    required this.bestStreak,
    required this.bossWins,
    required this.lastTrainingDay,
    required this.badges,
  });

  final int xp;
  final int streak;
  final int bestStreak;
  final int bossWins;
  final DateTime? lastTrainingDay;
  final Set<String> badges;
}

class GameRepository {
  GameRepository(this.db);

  final AppDatabase db;

  Stream<PlayerSnapshot> watchPlayer() =>
      (db.select(db.playerRows)..where((p) => p.id.equals(0)))
          .watchSingle()
          .map(_toSnapshot);

  Future<PlayerSnapshot> getPlayer() async => _toSnapshot(await (db
          .select(db.playerRows)
        ..where((p) => p.id.equals(0)))
      .getSingle());

  PlayerSnapshot _toSnapshot(PlayerRow row) => PlayerSnapshot(
        xp: row.xp,
        streak: row.streak,
        bestStreak: row.bestStreak,
        bossWins: row.bossWins,
        lastTrainingDay: row.lastTrainingDay,
        badges: {
          for (final b in row.badges.split(','))
            if (b.isNotEmpty) b,
        },
      );

  Stream<Map<String, GroupProgress>> watchProgress() =>
      db.select(db.groupProgressRows).watch().map(_toProgressMap);

  Future<Map<String, GroupProgress>> getProgress() async =>
      _toProgressMap(await db.select(db.groupProgressRows).get());

  Map<String, GroupProgress> _toProgressMap(List<GroupProgressRow> rows) => {
        for (final r in rows)
          r.groupId: GroupProgress(
            groupId: r.groupId,
            phase: r.phase,
            improvementStreak: r.improvementStreak,
            levelInPhase: r.levelInPhase,
          ),
      };

  /// Numéro du jour d'entraînement (nombre de jours distincts avec séance).
  Stream<int> watchDayNumber() => db.select(db.sessions).watch().map((rows) =>
      rows.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet().length);

  Future<void> ensureProgressRows(Iterable<String> groupIds) async {
    for (final id in groupIds) {
      await db.into(db.groupProgressRows).insert(
            GroupProgressRowsCompanion.insert(groupId: id),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Fixe la phase de départ d'un groupe (quiz de placement de l'onboarding).
  Future<void> setPhase(String groupId, int phase) async {
    await db.into(db.groupProgressRows).insert(
          GroupProgressRowsCompanion.insert(
              groupId: groupId, phase: Value(phase)),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// exerciseId → objectif fixe par tour.
  Future<Map<String, int>> getTargets() async {
    final rows = await db.select(db.exerciseTargets).get();
    return {for (final r in rows) r.exerciseId: r.target};
  }

  Future<void> setTarget(String exerciseId, int target) async {
    await db.into(db.exerciseTargets).insert(
          ExerciseTargetsCompanion.insert(
              exerciseId: exerciseId, target: target),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<BadgeStats> badgeStats() async {
    final sessionCount = await db
        .customSelect('SELECT COUNT(*) AS c FROM sessions', readsFrom: {db.sessions})
        .getSingle()
        .then((r) => r.read<int>('c'));
    final totalReps = await db
        .customSelect(
            'SELECT COALESCE(SUM(reps), 0) AS c FROM set_logs WHERE is_duration = 0',
            readsFrom: {db.setLogs})
        .getSingle()
        .then((r) => r.read<int>('c'));
    final bestRounds = await db
        .customSelect('SELECT COALESCE(MAX(rounds), 0) AS c FROM sessions',
            readsFrom: {db.sessions})
        .getSingle()
        .then((r) => r.read<int>('c'));
    final player = await getPlayer();
    final progress = await getProgress();
    return BadgeStats(
      totalSessions: sessionCount,
      totalReps: totalReps,
      streak: player.streak,
      bestRounds: bestRounds,
      bossWins: player.bossWins,
      phases: {for (final e in progress.entries) e.key: e.value.phase},
    );
  }

  Stream<List<SessionRow>> watchSessions() => (db.select(db.sessions)
        ..orderBy([(s) => OrderingTerm.desc(s.date)]))
      .watch();

  Future<Map<String, int>> totalRepsByGroup() async {
    final rows = await db.customSelect(
      'SELECT group_id AS gid, COALESCE(SUM(reps), 0) AS c '
      'FROM set_logs WHERE is_duration = 0 GROUP BY group_id',
      readsFrom: {db.setLogs},
    ).get();
    return {for (final r in rows) r.read<String>('gid'): r.read<int>('c')};
  }

  Future<void> resetAll() async {
    await db.transaction(() async {
      await db.delete(db.setLogs).go();
      await db.delete(db.sessions).go();
      await db.delete(db.exerciseTargets).go();
      await db.delete(db.groupProgressRows).go();
      await (db.update(db.playerRows)..where((p) => p.id.equals(0))).write(
        const PlayerRowsCompanion(
          xp: Value(0),
          streak: Value(0),
          bestStreak: Value(0),
          bossWins: Value(0),
          lastTrainingDay: Value(null),
          badges: Value(''),
        ),
      );
    });
  }
}

/// Orchestration de la fin de séance : persistance + progression + récompenses.
class WorkoutService {
  WorkoutService(this.repo);

  final GameRepository repo;

  Future<SessionResult> completeSession({
    required WorkoutPlan plan,
    required List<SetLog> sets,
    required Duration elapsed,
    required int rounds,
    required Profile profile,
    DateTime? now,
  }) async {
    final db = repo.db;
    final today = now ?? DateTime.now();
    final player = await repo.getPlayer();
    final progress = await repo.getProgress();

    // Numéro du jour du voyage 365 (jours distincts avec séance, aujourd'hui inclus).
    final trainedDays = (await db.select(db.sessions).get())
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
      ..add(DateTime(today.year, today.month, today.day));
    final dayNumber = trainedDays.length;

    // --- Boss fight : toutes les séries du mouvement boss à l'objectif +2 ---
    final bossGroupId = plan.bossGroupId;
    var bossWon = false;
    if (bossGroupId != null) {
      final bossMovement =
          plan.movements.firstWhere((m) => m.isBoss && m.group.id == bossGroupId);
      bossWon = Gamification.bossDefeated(
        bossSets:
            sets.where((s) => s.exerciseId == bossMovement.exercise.id),
        target: bossMovement.effectiveTarget ?? 10,
      );
    }

    // --- XP ---
    final streak = Gamification.streakAfterSession(
      current: player.streak,
      lastTrainingDay: player.lastTrainingDay,
      today: today,
      trainingDays: profile.trainingDays,
    );
    final xpReps = Gamification.xpFromSets(sets);
    final xpStreak = Gamification.streakBonus(streak);
    final xpBoss = bossWon ? Gamification.bossBonus : 0;
    final xpTotal = xpReps + Gamification.completionBonus + xpStreak + xpBoss;
    final levelBefore = Gamification.levelInfo(player.xp).level;
    final levelAfter = Gamification.levelInfo(player.xp + xpTotal).level;

    // --- Calibration : les mouvements sans objectif en reçoivent un ---
    final calibratedTargets = <String, int>{};
    for (final movement in plan.movements.where((m) => m.isCalibration)) {
      final movementSets =
          sets.where((s) => s.exerciseId == movement.exercise.id).toList();
      if (movementSets.isEmpty) continue;
      final best =
          movementSets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
      calibratedTargets[movement.exercise.id] = Gamification.calibrationTarget(
        best: best,
        isDuration: movement.exercise.type == ExerciseType.duration,
      );
    }

    // --- Progression par groupe : objectifs tenus → streak → +2 ou boss ---
    final phaseUps = <String, int>{};
    final targetUps = <String, ({int from, int to})>{};
    final progressUpdates = <String, GroupProgress>{};
    final movementsByGroup = <String, List<Movement>>{};
    for (final m in plan.movements) {
      movementsByGroup.putIfAbsent(m.group.id, () => []).add(m);
    }

    for (final entry in movementsByGroup.entries) {
      final groupId = entry.key;
      final current = progress[groupId] ?? GroupProgress(groupId: groupId);

      if (groupId == bossGroupId) {
        if (bossWon) {
          final newPhase = current.phase + 1;
          phaseUps[groupId] = newPhase;
          progressUpdates[groupId] = current.copyWith(
              phase: newPhase, improvementStreak: 0, levelInPhase: 1);
        }
        // Boss perdu : le compteur reste à 2, le boss se représentera.
        continue;
      }

      final targeted = {
        for (final m in entry.value)
          if (m.target != null) m.exercise.id: m.target!,
      };
      if (targeted.isEmpty) continue; // groupe entièrement en calibration
      final groupSets =
          sets.where((s) => s.groupId == groupId).toList();
      final succeeded = Gamification.groupSucceeded(
          sets: groupSets, targetByExercise: targeted);
      var nextStreak = Gamification.nextSuccessStreak(
          current: current.improvementStreak, succeeded: succeeded);

      var levelInPhase = current.levelInPhase;
      if (nextStreak >= 2 && current.phase < 4) {
        // Maîtrise atteinte → boss prêt ; sinon micro-progression +2,
        // niveau suivant dans la phase, et on repart.
        final allMastered = entry.value.every((m) =>
            m.target == null ||
            Gamification.isMastered(
                target: m.target!,
                isDuration: m.exercise.type == ExerciseType.duration));
        if (!allMastered) {
          for (final m in entry.value) {
            if (m.target == null) continue;
            final to = m.target! +
                Gamification.targetIncrement(
                    m.exercise.type == ExerciseType.duration);
            targetUps[m.exercise.id] = (from: m.target!, to: to);
          }
          nextStreak = 0;
          levelInPhase += 1;
        }
      }
      if (nextStreak != current.improvementStreak ||
          levelInPhase != current.levelInPhase) {
        progressUpdates[groupId] = current.copyWith(
            improvementStreak: nextStreak, levelInPhase: levelInPhase);
      }
    }

    // --- Badges ---
    final statsBefore = await repo.badgeStats();
    final stats = BadgeStats(
      totalSessions: statsBefore.totalSessions + 1,
      totalReps: statsBefore.totalReps +
          sets.where((s) => !s.isDuration).fold(0, (a, s) => a + s.reps),
      streak: streak,
      bestRounds:
          rounds > statsBefore.bestRounds ? rounds : statsBefore.bestRounds,
      bossWins: player.bossWins + (bossWon ? 1 : 0),
      phases: {
        for (final e in statsBefore.phases.entries)
          e.key: phaseUps[e.key] ?? e.value,
      },
    );
    final newBadges = newlyUnlockedBadges(stats, player.badges);

    // --- Persistance transactionnelle ---
    await db.transaction(() async {
      final sessionId = await db.into(db.sessions).insert(SessionsCompanion.insert(
            date: today,
            durationSeconds: elapsed.inSeconds,
            rounds: rounds,
            xp: xpTotal,
            bossGroupId: Value(bossGroupId),
            bossWon: Value(bossWon),
          ));
      for (final s in sets) {
        await db.into(db.setLogs).insert(SetLogsCompanion.insert(
              sessionId: sessionId,
              exerciseId: s.exerciseId,
              groupId: s.groupId,
              phase: s.phase,
              round: s.round,
              reps: s.reps,
              weighted: Value(s.weighted),
              isDuration: Value(s.isDuration),
            ));
      }
      for (final p in progressUpdates.values) {
        await db.into(db.groupProgressRows).insert(
              GroupProgressRowsCompanion.insert(
                groupId: p.groupId,
                phase: Value(p.phase),
                improvementStreak: Value(p.improvementStreak),
                levelInPhase: Value(p.levelInPhase),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final e in calibratedTargets.entries) {
        await db.into(db.exerciseTargets).insert(
              ExerciseTargetsCompanion.insert(
                  exerciseId: e.key, target: e.value),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final e in targetUps.entries) {
        await db.into(db.exerciseTargets).insert(
              ExerciseTargetsCompanion.insert(
                  exerciseId: e.key, target: e.value.to),
              mode: InsertMode.insertOrReplace,
            );
      }
      await (db.update(db.playerRows)..where((p) => p.id.equals(0))).write(
        PlayerRowsCompanion(
          xp: Value(player.xp + xpTotal),
          streak: Value(streak),
          bestStreak: Value(streak > player.bestStreak ? streak : player.bestStreak),
          bossWins: Value(player.bossWins + (bossWon ? 1 : 0)),
          lastTrainingDay: Value(DateTime(today.year, today.month, today.day)),
          badges: Value(
              ({...player.badges, for (final b in newBadges) b.id}).join(',')),
        ),
      );
    });

    return SessionResult(
      xpTotal: xpTotal,
      xpFromReps: xpReps,
      xpCompletionBonus: Gamification.completionBonus,
      xpStreakBonus: xpStreak,
      xpBossBonus: xpBoss,
      totalReps: sets.where((s) => !s.isDuration).fold(0, (a, s) => a + s.reps),
      rounds: rounds,
      duration: elapsed,
      streak: streak,
      newBadges: [for (final b in newBadges) b.id],
      bossGroupId: bossGroupId,
      bossWon: bossWon,
      phaseUps: phaseUps,
      targetUps: targetUps,
      calibratedTargets: calibratedTargets,
      playerLevelBefore: levelBefore,
      playerLevelAfter: levelAfter,
      dayNumber: dayNumber,
    );
  }
}
