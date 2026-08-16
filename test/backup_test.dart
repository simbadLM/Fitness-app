import 'package:drift/native.dart';
import 'package:fitness_game/data/backup.dart';
import 'package:fitness_game/data/db.dart';
import 'package:fitness_game/data/repositories.dart';
import 'package:fitness_game/domain/content.dart';
import 'package:fitness_game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aller-retour export → base vierge → import : rien ne doit se perdre.
void main() {
  test('sauvegarde : export puis restauration à l\'identique', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    final repo = GameRepository(db);
    final service = WorkoutService(repo);
    final backup = BackupService(repo);
    addTearDown(db.close);

    const profile = Profile(
      name: 'Simon',
      sex: Sex.male,
      equipment: {Equipment.kettlebell},
      trainingDays: {1, 2, 4},
    );
    await repo.ensureProgressRows(['armsChest', 'legs', 'abs', 'back']);
    await repo.setPhase('legs', 2);
    await repo.setTarget('bw-squats', 12);

    // Une séance réelle pour peupler l'historique.
    const exercise = Exercise(
        id: 'bw-squats', name: 'Bodyweight Squats', picto: PictoType.squat);
    const group = MuscleGroup(
        id: 'legs', nameFr: 'Jambes', nameEn: 'Legs', phases: []);
    final plan = WorkoutPlan(movements: [
      Movement(group: group, exercise: exercise, phase: 2, target: 12),
    ]);
    await service.completeSession(
      plan: plan,
      sets: const [
        SetLog(
            exerciseId: 'bw-squats',
            groupId: 'legs',
            phase: 2,
            round: 1,
            reps: 12),
        SetLog(
            exerciseId: 'bw-squats',
            groupId: 'legs',
            phase: 2,
            round: 2,
            reps: 13),
      ],
      elapsed: const Duration(minutes: 18),
      rounds: 2,
      profile: profile,
      now: DateTime(2026, 8, 3),
    );

    final json = await backup.exportJson(profile, now: DateTime(2026, 8, 4));

    // Base vierge → restauration.
    final db2 = AppDatabase.withExecutor(NativeDatabase.memory());
    final repo2 = GameRepository(db2);
    addTearDown(db2.close);
    final restoredProfile = await BackupService(repo2).restore(json);

    expect(restoredProfile.name, 'Simon');
    expect(restoredProfile.equipment, {Equipment.kettlebell});
    expect(restoredProfile.trainingDays, {1, 2, 4});

    final player = await repo2.getPlayer();
    final original = await repo.getPlayer();
    expect(player.xp, original.xp);
    expect(player.streak, original.streak);
    expect(player.badges, original.badges);
    expect(player.lastTrainingDay, original.lastTrainingDay);

    final progress = await repo2.getProgress();
    expect(progress['legs']!.phase, 2);

    expect(await repo2.getTargets(), await repo.getTargets());

    final sessions = await db2.select(db2.sessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.single.rounds, 2);
    final sets = await db2.select(db2.setLogs).get();
    expect(sets, hasLength(2));
    expect(sets.every((s) => s.sessionId == sessions.single.id), isTrue);
  });

  test('restore refuse un fichier invalide', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final backup = BackupService(GameRepository(db));
    expect(() => backup.restore('{"app":"autre"}'),
        throwsA(isA<FormatException>()));
  });
}
