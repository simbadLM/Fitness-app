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
          ),
      };

  Future<void> ensureProgressRows(Iterable<String> groupIds) async {
    for (final id in groupIds) {
      await db.into(db.groupProgressRows).insert(
            GroupProgressRowsCompanion.insert(groupId: id),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Dernière série enregistrée pour chaque exercice (la plus récente).
  Future<Map<String, int>> lastSetRepsByExercise() async {
    final rows = await db.customSelect(
      'SELECT sl.exercise_id AS eid, sl.reps AS reps '
      'FROM set_logs sl JOIN sessions s ON s.id = sl.session_id '
      'ORDER BY s.date ASC, sl.round ASC, sl.id ASC',
      readsFrom: {db.setLogs, db.sessions},
    ).get();
    final result = <String, int>{};
    for (final row in rows) {
      result[row.read<String>('eid')] = row.read<int>('reps');
    }
    return result;
  }

  /// Dernière série (la plus tardive) d'un exercice pour chacune des deux
  /// dernières séances où il apparaît : `[avant-dernière, dernière]`.
  Future<List<int>> lastTwoFinalSets(String exerciseId) async {
    final rows = await db.customSelect(
      'SELECT sl.session_id AS sid, MAX(sl.round) AS r, '
      '(SELECT reps FROM set_logs WHERE session_id = sl.session_id '
      ' AND exercise_id = sl.exercise_id ORDER BY round DESC, id DESC LIMIT 1) AS reps '
      'FROM set_logs sl JOIN sessions s ON s.id = sl.session_id '
      'WHERE sl.exercise_id = ? '
      'GROUP BY sl.session_id ORDER BY s.date DESC LIMIT 2',
      variables: [Variable.withString(exerciseId)],
      readsFrom: {db.setLogs, db.sessions},
    ).get();
    return rows.reversed.map((r) => r.read<int>('reps')).toList();
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

    // --- Boss fight ---
    final bossGroupId = plan.bossGroupId;
    var bossWon = false;
    if (bossGroupId != null) {
      final bossMovement =
          plan.movements.firstWhere((m) => m.isBoss && m.group.id == bossGroupId);
      bossWon = Gamification.bossDefeated(
        bossSets:
            sets.where((s) => s.exerciseId == bossMovement.exercise.id),
        target: bossMovement.bossTarget ?? 10,
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

    // --- Progression par groupe (rule of thumb) ---
    final phaseUps = <String, int>{};
    final progressUpdates = <String, GroupProgress>{};
    for (final movement in plan.movements.where((m) => !m.isFocus)) {
      final current =
          progress[movement.group.id] ?? GroupProgress(groupId: movement.group.id);
      if (movement.isBoss) {
        if (bossWon) {
          final newPhase = current.phase + 1;
          phaseUps[movement.group.id] = newPhase;
          progressUpdates[movement.group.id] =
              current.copyWith(phase: newPhase, improvementStreak: 0);
        }
        // Boss perdu : le compteur reste à 2, le boss se représentera.
        continue;
      }
      final history = await repo.lastTwoFinalSets(movement.exercise.id);
      final todayFinal = _finalSetReps(sets, movement.exercise.id);
      if (todayFinal == null) continue;
      final previous = history.isNotEmpty ? history.last : null;
      final nextStreak = Gamification.nextImprovementStreak(
        current: current.improvementStreak,
        lastSetReps: todayFinal,
        previousLastSetReps: previous,
      );
      if (nextStreak != current.improvementStreak) {
        progressUpdates[movement.group.id] =
            current.copyWith(improvementStreak: nextStreak);
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
              ),
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
      playerLevelBefore: levelBefore,
      playerLevelAfter: levelAfter,
    );
  }

  int? _finalSetReps(List<SetLog> sets, String exerciseId) {
    final matching = sets.where((s) => s.exerciseId == exerciseId).toList();
    return matching.isEmpty ? null : matching.last.reps;
  }
}
