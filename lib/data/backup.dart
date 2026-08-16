import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/models.dart';
import 'db.dart';
import 'repositories.dart';

/// Sauvegarde locale complète : profil, progression, objectifs, historique.
/// Export/import en JSON — survit aux réinstallations et permet de migrer
/// vers un nouveau téléphone.
class BackupService {
  BackupService(this.repo);

  static const int formatVersion = 1;

  final GameRepository repo;

  Future<String> exportJson(Profile profile, {DateTime? now}) async {
    final db = repo.db;
    final sessions = await db.select(db.sessions).get();
    final sets = await db.select(db.setLogs).get();
    final progress = await db.select(db.groupProgressRows).get();
    final targets = await db.select(db.exerciseTargets).get();
    final player = await (db.select(db.playerRows)
          ..where((p) => p.id.equals(0)))
        .getSingle();

    return const JsonEncoder.withIndent('  ').convert({
      'app': '365',
      'formatVersion': formatVersion,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'profile': jsonDecode(profile.toJsonString()),
      'player': {
        'xp': player.xp,
        'streak': player.streak,
        'bestStreak': player.bestStreak,
        'bossWins': player.bossWins,
        'lastTrainingDay': player.lastTrainingDay?.toIso8601String(),
        'badges': player.badges,
      },
      'progress': [
        for (final p in progress)
          {
            'groupId': p.groupId,
            'phase': p.phase,
            'improvementStreak': p.improvementStreak,
            'levelInPhase': p.levelInPhase,
          },
      ],
      'targets': [
        for (final t in targets)
          {'exerciseId': t.exerciseId, 'target': t.target},
      ],
      'sessions': [
        for (final s in sessions)
          {
            'id': s.id,
            'date': s.date.toIso8601String(),
            'durationSeconds': s.durationSeconds,
            'rounds': s.rounds,
            'xp': s.xp,
            'bossGroupId': s.bossGroupId,
            'bossWon': s.bossWon,
          },
      ],
      'sets': [
        for (final s in sets)
          {
            'sessionId': s.sessionId,
            'exerciseId': s.exerciseId,
            'groupId': s.groupId,
            'phase': s.phase,
            'round': s.round,
            'reps': s.reps,
            'weighted': s.weighted,
            'isDuration': s.isDuration,
          },
      ],
    });
  }

  /// Remplace toutes les données locales par celles de la sauvegarde.
  /// Retourne le profil restauré (à réappliquer aux préférences).
  Future<Profile> restore(String source) async {
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['app'] != '365' || json['formatVersion'] is! int) {
      throw const FormatException('Fichier de sauvegarde 365 invalide.');
    }
    if ((json['formatVersion'] as int) > formatVersion) {
      throw const FormatException(
          'Sauvegarde créée par une version plus récente de l\'app.');
    }
    final profile = Profile.fromJsonString(jsonEncode(json['profile']));
    final db = repo.db;

    await db.transaction(() async {
      await db.delete(db.setLogs).go();
      await db.delete(db.sessions).go();
      await db.delete(db.groupProgressRows).go();
      await db.delete(db.exerciseTargets).go();

      final player = json['player'] as Map<String, dynamic>;
      await (db.update(db.playerRows)..where((p) => p.id.equals(0))).write(
        PlayerRowsCompanion(
          xp: Value(player['xp'] as int),
          streak: Value(player['streak'] as int),
          bestStreak: Value(player['bestStreak'] as int),
          bossWins: Value(player['bossWins'] as int? ?? 0),
          lastTrainingDay: Value(player['lastTrainingDay'] == null
              ? null
              : DateTime.parse(player['lastTrainingDay'] as String)),
          badges: Value(player['badges'] as String? ?? ''),
        ),
      );

      for (final p in (json['progress'] as List).cast<Map<String, dynamic>>()) {
        await db.into(db.groupProgressRows).insert(
              GroupProgressRowsCompanion.insert(
                groupId: p['groupId'] as String,
                phase: Value(p['phase'] as int),
                improvementStreak: Value(p['improvementStreak'] as int),
                levelInPhase: Value(p['levelInPhase'] as int? ?? 1),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final t in (json['targets'] as List).cast<Map<String, dynamic>>()) {
        await db.into(db.exerciseTargets).insert(
              ExerciseTargetsCompanion.insert(
                exerciseId: t['exerciseId'] as String,
                target: t['target'] as int,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      // Les identifiants de séance sont réattribués ; on mappe les anciens
      // vers les nouveaux pour raccrocher les séries.
      final idMap = <int, int>{};
      for (final s in (json['sessions'] as List).cast<Map<String, dynamic>>()) {
        final newId = await db.into(db.sessions).insert(SessionsCompanion.insert(
              date: DateTime.parse(s['date'] as String),
              durationSeconds: s['durationSeconds'] as int,
              rounds: s['rounds'] as int,
              xp: s['xp'] as int,
              bossGroupId: Value(s['bossGroupId'] as String?),
              bossWon: Value(s['bossWon'] as bool? ?? false),
            ));
        idMap[s['id'] as int] = newId;
      }
      for (final s in (json['sets'] as List).cast<Map<String, dynamic>>()) {
        final sessionId = idMap[s['sessionId'] as int];
        if (sessionId == null) continue;
        await db.into(db.setLogs).insert(SetLogsCompanion.insert(
              sessionId: sessionId,
              exerciseId: s['exerciseId'] as String,
              groupId: s['groupId'] as String,
              phase: s['phase'] as int,
              round: s['round'] as int,
              reps: s['reps'] as int,
              weighted: Value(s['weighted'] as bool? ?? false),
              isDuration: Value(s['isDuration'] as bool? ?? false),
            ));
      }
    });

    return profile;
  }
}
