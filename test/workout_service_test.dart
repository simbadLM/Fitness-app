import 'dart:io';

import 'package:drift/native.dart';
import 'package:fitness_game/data/db.dart';
import 'package:fitness_game/data/repositories.dart';
import 'package:fitness_game/domain/content.dart';
import 'package:fitness_game/domain/models.dart';
import 'package:fitness_game/domain/workout_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boucle de jeu complète sur une base réelle (SQLite en mémoire) :
/// calibration → objectifs tenus → +2 → maîtrise → boss → phase débloquée.
void main() {
  late Program program;
  late AppDatabase db;
  late GameRepository repo;
  late WorkoutService service;

  setUpAll(() {
    program =
        Program.fromJsonString(File('content/program.json').readAsStringSync());
  });

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repo = GameRepository(db);
    service = WorkoutService(repo);
    await repo.ensureProgressRows(program.groups.map((g) => g.id));
  });

  tearDown(() => db.close());

  const profile = Profile(name: 'Test', sex: Sex.male);

  Future<WorkoutPlan> plan(DateTime date) async => WorkoutGenerator.generate(
        program: program,
        progress: await repo.getProgress(),
        owned: const {},
        date: date,
        targets: await repo.getTargets(),
      );

  /// Joue une séance : chaque mouvement fait [rounds] séries à [reps].
  Future<SessionResult> play(WorkoutPlan p, DateTime date,
      {required int Function(Movement) reps, int rounds = 3}) {
    final sets = <SetLog>[
      for (var round = 1; round <= rounds; round++)
        for (final m in p.movements)
          SetLog(
            exerciseId: m.exercise.id,
            groupId: m.group.id,
            phase: m.phase,
            round: round,
            reps: reps(m),
            isDuration: m.exercise.type == ExerciseType.duration,
          ),
    ];
    return service.completeSession(
      plan: p,
      sets: sets,
      elapsed: const Duration(minutes: 18),
      rounds: rounds,
      profile: profile,
      now: date,
    );
  }

  test('séance 1 : tout est en calibration et fixe les objectifs', () async {
    final day1 = DateTime(2026, 8, 3);
    final p = await plan(day1);
    expect(p.movements.every((m) => m.isCalibration), isTrue);

    final result = await play(p, day1, reps: (m) => 10);
    expect(result.calibratedTargets.length, p.movements.length);
    // 70 % de 10 = 7.
    expect(result.calibratedTargets.values.every((t) => t == 7), isTrue);
    expect(result.streak, 1);
    expect(result.newBadges, contains('first_session'));

    final targets = await repo.getTargets();
    expect(targets.length, p.movements.length);
  });

  test('2 séances réussies sous la maîtrise → objectifs +2, pas de boss',
      () async {
    final day1 = DateTime(2026, 8, 3);
    await play(await plan(day1), day1, reps: (m) => 10); // calibration → 7

    final day2 = DateTime(2026, 8, 4);
    await play(await plan(day2), day2, reps: (m) => m.effectiveTarget ?? 10);
    final day3 = DateTime(2026, 8, 6);
    final r3 = await play(await plan(day3), day3,
        reps: (m) => m.effectiveTarget ?? 10);

    // 2 réussites consécutives, objectifs (7) < maîtrise (15) → +2, et aucun
    // boss ne doit être prêt (la maîtrise n'est pas atteinte).
    expect(r3.targetUps, isNotEmpty);
    expect(r3.targetUps.values.every((t) => t.to == t.from + 2), isTrue);
    final progress = await repo.getProgress();
    expect(progress.values.every((g) => g.bossStatus != BossStatus.ready),
        isTrue);
  });

  test('maîtrise atteinte → boss prêt, victoire → phase débloquée', () async {
    // Objectifs directement au seuil de maîtrise pour tous les exercices phase 1.
    for (final g in program.groups) {
      for (final e in g.exercisesForPhase(1)) {
        await repo.setTarget(e.id, e.type == ExerciseType.duration ? 60 : 15);
      }
    }

    // 2 séances réussies → un groupe passe boss ready (pas de bump : maîtrisé).
    final day1 = DateTime(2026, 8, 3);
    final r1 = await play(await plan(day1), day1,
        reps: (m) => m.effectiveTarget!);
    expect(r1.targetUps, isEmpty);
    final day2 = DateTime(2026, 8, 4);
    await play(await plan(day2), day2, reps: (m) => m.effectiveTarget!);

    final progress = await repo.getProgress();
    expect(progress.values.where((g) => g.bossStatus == BossStatus.ready),
        isNotEmpty);

    // Séance suivante : un boss est injecté ; toutes ses séries à +2 → phase 2.
    final day3 = DateTime(2026, 8, 6);
    final p3 = await plan(day3);
    expect(p3.bossGroupId, isNotNull);
    final r3 = await play(p3, day3, reps: (m) => m.effectiveTarget!);
    expect(r3.bossWon, isTrue);
    expect(r3.phaseUps[p3.bossGroupId], 2);
    expect(r3.newBadges, contains('boss_first'));

    final after = await repo.getProgress();
    expect(after[p3.bossGroupId]!.phase, 2);
    expect(after[p3.bossGroupId]!.improvementStreak, 0);
  });

  test('boss perdu : la phase ne bouge pas et le boss se représente', () async {
    for (final g in program.groups) {
      for (final e in g.exercisesForPhase(1)) {
        await repo.setTarget(e.id, e.type == ExerciseType.duration ? 60 : 15);
      }
    }
    final day1 = DateTime(2026, 8, 3);
    await play(await plan(day1), day1, reps: (m) => m.effectiveTarget!);
    final day2 = DateTime(2026, 8, 4);
    await play(await plan(day2), day2, reps: (m) => m.effectiveTarget!);

    final day3 = DateTime(2026, 8, 6);
    final p3 = await plan(day3);
    final bossGroup = p3.bossGroupId!;
    // Le boss échoue (une rep sous l'objectif relevé), le reste réussit.
    final r3 = await play(p3, day3,
        reps: (m) => m.isBoss ? m.effectiveTarget! - 1 : m.effectiveTarget!);
    expect(r3.bossWon, isFalse);
    expect(r3.phaseUps, isEmpty);

    final after = await repo.getProgress();
    expect(after[bossGroup]!.phase, 1);
    expect(after[bossGroup]!.bossStatus, BossStatus.ready);

    // Le boss est bien reproposé à la séance suivante.
    final day4 = DateTime(2026, 8, 7);
    expect((await plan(day4)).bossGroupId, bossGroup);
  });
}
