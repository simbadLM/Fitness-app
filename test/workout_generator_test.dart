import 'dart:io';

import 'package:fitness_game/domain/content.dart';
import 'package:fitness_game/domain/models.dart';
import 'package:fitness_game/domain/workout_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Program program;

  setUpAll(() {
    program =
        Program.fromJsonString(File('content/program.json').readAsStringSync());
  });

  group('Intégrité du contenu', () {
    test('4 groupes musculaires, 4 phases chacun', () {
      expect(program.groups, hasLength(4));
      for (final g in program.groups) {
        expect(g.phases, hasLength(4));
        expect(g.phases.map((p) => p.phase), [1, 2, 3, 4]);
      }
    });

    test('identifiants d\'exercices uniques', () {
      final ids = <String>[];
      for (final g in program.groups) {
        for (final p in g.phases) {
          ids.addAll(p.exercises.map((e) => e.id));
        }
      }
      expect(ids.toSet().length, ids.length);
    });

    test('les phases 1 à 3 ont des exercices, la phase 4 a une règle', () {
      for (final g in program.groups) {
        for (final p in g.phases) {
          if (p.phase < 4) {
            expect(p.exercises, isNotEmpty, reason: '${g.id} phase ${p.phase}');
          } else {
            expect(p.rule, isNotNull);
            expect(g.exercisesForPhase(4), equals(g.exercisesForPhase(3)));
          }
        }
      }
    });

    test('chaque phase reste jouable sans aucun matériel', () {
      for (final g in program.groups) {
        for (var phase = 1; phase <= 4; phase++) {
          final available = g
              .exercisesForPhase(phase)
              .where((e) => e.availableWith(const {}))
              .toList();
          expect(available, isNotEmpty,
              reason: '${g.id} phase $phase injouable sans matériel');
        }
      }
    });
  });

  group('Génération de la quête du jour', () {
    Map<String, GroupProgress> progressAt(int phase,
            {int improvementStreak = 0}) =>
        {
          for (final g in program.groups)
            g.id: GroupProgress(
                groupId: g.id,
                phase: phase,
                improvementStreak: improvementStreak),
        };

    test('1 mouvement par groupe + focus du lundi (bras/pecs)', () {
      final plan = WorkoutGenerator.generate(
        program: program,
        progress: progressAt(1),
        owned: const {},
        date: DateTime(2026, 8, 3), // lundi
      );
      expect(plan.focusGroupId, 'armsChest');
      expect(plan.movements, hasLength(5));
      expect(plan.movements.where((m) => m.group.id == 'armsChest'),
          hasLength(2));
      expect(plan.movements.where((m) => m.isFocus), hasLength(1));
    });

    test('samedi : circuit sans focus, 4 mouvements', () {
      final plan = WorkoutGenerator.generate(
        program: program,
        progress: progressAt(1),
        owned: const {},
        date: DateTime(2026, 8, 8), // samedi
      );
      expect(plan.focusGroupId, isNull);
      expect(plan.movements, hasLength(4));
    });

    test('respecte le matériel possédé', () {
      final plan = WorkoutGenerator.generate(
        program: program,
        progress: progressAt(2),
        owned: const {},
        date: DateTime(2026, 8, 4),
      );
      for (final m in plan.movements) {
        expect(m.exercise.availableWith(const {}), isTrue,
            reason: '${m.exercise.id} exige du matériel non possédé');
      }
    });

    test('déterministe pour une même date', () {
      WorkoutPlan gen() => WorkoutGenerator.generate(
            program: program,
            progress: progressAt(1),
            owned: const {Equipment.kettlebell},
            date: DateTime(2026, 8, 4),
          );
      expect(
        gen().movements.map((m) => m.exercise.id).toList(),
        gen().movements.map((m) => m.exercise.id).toList(),
      );
    });

    test('boss injecté quand un groupe est prêt', () {
      final progress = progressAt(1);
      progress['legs'] =
          const GroupProgress(groupId: 'legs', phase: 1, improvementStreak: 2);
      final plan = WorkoutGenerator.generate(
        program: program,
        progress: progress,
        owned: const {},
        date: DateTime(2026, 8, 4),
        lastSetReps: const {},
      );
      expect(plan.bossGroupId, 'legs');
      final boss = plan.movements.singleWhere((m) => m.isBoss);
      expect(boss.group.id, 'legs');
      expect(boss.bossTarget, isNotNull);
    });

    test('un seul boss par séance même si plusieurs groupes sont prêts', () {
      final plan = WorkoutGenerator.generate(
        program: program,
        progress: progressAt(1, improvementStreak: 2),
        owned: const {},
        date: DateTime(2026, 8, 4),
      );
      expect(plan.movements.where((m) => m.isBoss), hasLength(1));
    });

    test('phase 4 : lest appliqué seulement avec du matériel de charge', () {
      final withWeight = WorkoutGenerator.generate(
        program: program,
        progress: progressAt(4),
        owned: const {Equipment.kettlebell},
        date: DateTime(2026, 8, 4),
      );
      expect(withWeight.movements.every((m) => m.weighted), isTrue);

      final without = WorkoutGenerator.generate(
        program: program,
        progress: progressAt(4),
        owned: const {},
        date: DateTime(2026, 8, 4),
      );
      expect(without.movements.every((m) => m.weighted), isFalse);
    });

    test('cible boss = dernière série + 2', () {
      final progress = progressAt(1);
      progress['abs'] =
          const GroupProgress(groupId: 'abs', phase: 1, improvementStreak: 2);
      final plan = WorkoutGenerator.generate(
        program: program,
        progress: progress,
        owned: const {},
        date: DateTime(2026, 8, 4),
        lastSetReps: {
          for (final e in program.group('abs').exercisesForPhase(1)) e.id: 20,
        },
      );
      final boss = plan.movements.singleWhere((m) => m.isBoss);
      expect(boss.bossTarget, 22);
    });
  });
}
