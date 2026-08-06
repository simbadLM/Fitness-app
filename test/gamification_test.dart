import 'package:fitness_game/domain/gamification.dart';
import 'package:fitness_game/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XP', () {
    test('1 XP par répétition', () {
      const set = SetLog(
          exerciseId: 'x', groupId: 'g', phase: 1, round: 1, reps: 12);
      expect(Gamification.xpForSet(set), 12);
    });

    test('1 XP par 5 s pour les exercices chronométrés', () {
      const plank = SetLog(
          exerciseId: 'x',
          groupId: 'g',
          phase: 1,
          round: 1,
          reps: 45,
          isDuration: true);
      expect(Gamification.xpForSet(plank), 9);
    });

    test('bonus de streak plafonné à 100', () {
      expect(Gamification.streakBonus(3), 15);
      expect(Gamification.streakBonus(50), 100);
    });

    test('niveaux : seuils croissants', () {
      expect(Gamification.levelInfo(0).level, 1);
      expect(Gamification.levelInfo(199).level, 1);
      expect(Gamification.levelInfo(200).level, 2);
      expect(Gamification.levelInfo(200 + 300).level, 3);
      final info = Gamification.levelInfo(250);
      expect(info.inLevel, 50);
      expect(info.forNext, 300);
    });
  });

  group('Streak', () {
    // Profil du guide : lun, mar, jeu, ven, sam (repos mer + dim).
    const days = {1, 2, 4, 5, 6};

    test('première séance démarre à 1', () {
      expect(
        Gamification.streakAfterSession(
          current: 0,
          lastTrainingDay: null,
          today: DateTime(2026, 8, 3),
          trainingDays: days,
        ),
        1,
      );
    });

    test('jour consécutif incrémente', () {
      expect(
        Gamification.streakAfterSession(
          current: 3,
          lastTrainingDay: DateTime(2026, 8, 3), // lundi
          today: DateTime(2026, 8, 4), // mardi
          trainingDays: days,
        ),
        4,
      );
    });

    test('le jour de repos planifié ne casse pas la série', () {
      // Mardi 4 → jeudi 6 en passant le mercredi (repos).
      expect(
        Gamification.streakAfterSession(
          current: 4,
          lastTrainingDay: DateTime(2026, 8, 4),
          today: DateTime(2026, 8, 6),
          trainingDays: days,
        ),
        5,
      );
    });

    test('un jour planifié manqué casse la série', () {
      // Lundi 3 → jeudi 6 : le mardi (planifié) a été manqué.
      expect(
        Gamification.streakAfterSession(
          current: 4,
          lastTrainingDay: DateTime(2026, 8, 3),
          today: DateTime(2026, 8, 6),
          trainingDays: days,
        ),
        1,
      );
    });

    test('deux séances le même jour ne comptent qu\'une fois', () {
      expect(
        Gamification.streakAfterSession(
          current: 4,
          lastTrainingDay: DateTime(2026, 8, 6),
          today: DateTime(2026, 8, 6),
          trainingDays: days,
        ),
        4,
      );
    });

    test('streak affiché tombe à 0 quand un jour planifié est manqué', () {
      expect(
        Gamification.currentStreak(
          stored: 5,
          lastTrainingDay: DateTime(2026, 8, 3),
          today: DateTime(2026, 8, 6),
          trainingDays: days,
        ),
        0,
      );
      expect(
        Gamification.currentStreak(
          stored: 5,
          lastTrainingDay: DateTime(2026, 8, 4),
          today: DateTime(2026, 8, 6),
          trainingDays: days,
        ),
        5,
      );
    });
  });

  group('Objectifs fixes, maîtrise & boss', () {
    test('réussite de groupe : toutes les séries à l\'objectif', () {
      const targets = {'x': 10};
      const good = [
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 1, reps: 10),
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 2, reps: 11),
      ];
      const bad = [
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 1, reps: 10),
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 2, reps: 8),
      ];
      expect(
          Gamification.groupSucceeded(sets: good, targetByExercise: targets),
          isTrue);
      expect(
          Gamification.groupSucceeded(sets: bad, targetByExercise: targets),
          isFalse);
      // Aucune série sur un exercice à objectif : pas une réussite.
      expect(
          Gamification.groupSucceeded(
              sets: const [], targetByExercise: targets),
          isFalse);
      // Les séries d'exercices en calibration sont ignorées.
      const onlyCalibration = [
        SetLog(exerciseId: 'y', groupId: 'g', phase: 1, round: 1, reps: 3),
      ];
      expect(
          Gamification.groupSucceeded(
              sets: onlyCalibration, targetByExercise: targets),
          isFalse);
    });

    test('compteur de séances réussies consécutives', () {
      expect(Gamification.nextSuccessStreak(current: 0, succeeded: true), 1);
      expect(Gamification.nextSuccessStreak(current: 1, succeeded: true), 2);
      expect(Gamification.nextSuccessStreak(current: 1, succeeded: false), 0);
    });

    test('statut boss dérivé du compteur', () {
      expect(const GroupProgress(groupId: 'g').bossStatus, BossStatus.normal);
      expect(
          const GroupProgress(groupId: 'g', improvementStreak: 1).bossStatus,
          BossStatus.approaching);
      expect(
          const GroupProgress(groupId: 'g', improvementStreak: 2).bossStatus,
          BossStatus.ready);
      // En phase max, plus de boss.
      expect(
          const GroupProgress(groupId: 'g', phase: 4, improvementStreak: 2)
              .bossStatus,
          BossStatus.normal);
    });

    test('seuil de maîtrise : 15 reps ou 60 s', () {
      expect(Gamification.isMastered(target: 15, isDuration: false), isTrue);
      expect(Gamification.isMastered(target: 14, isDuration: false), isFalse);
      expect(Gamification.isMastered(target: 60, isDuration: true), isTrue);
      expect(Gamification.isMastered(target: 45, isDuration: true), isFalse);
    });

    test('calibration : ~70 % du meilleur effort, avec plancher', () {
      expect(Gamification.calibrationTarget(best: 20, isDuration: false), 14);
      expect(Gamification.calibrationTarget(best: 4, isDuration: false), 5);
      expect(Gamification.calibrationTarget(best: 60, isDuration: true), 42);
      expect(Gamification.calibrationTarget(best: 10, isDuration: true), 15);
    });

    test('boss vaincu : toutes les séries tiennent l\'objectif relevé', () {
      const allHold = [
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 1, reps: 12),
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 2, reps: 13),
      ];
      const oneFails = [
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 1, reps: 12),
        SetLog(exerciseId: 'x', groupId: 'g', phase: 1, round: 2, reps: 11),
      ];
      expect(Gamification.bossDefeated(bossSets: allHold, target: 12), isTrue);
      expect(
          Gamification.bossDefeated(bossSets: oneFails, target: 12), isFalse);
      expect(Gamification.bossDefeated(bossSets: const [], target: 12), isFalse);
    });
  });

  group('Badges', () {
    BadgeStats stats({
      int sessions = 0,
      int reps = 0,
      int streak = 0,
      int rounds = 0,
      int bossWins = 0,
      Map<String, int> phases = const {},
    }) =>
        BadgeStats(
          totalSessions: sessions,
          totalReps: reps,
          streak: streak,
          bestRounds: rounds,
          bossWins: bossWins,
          phases: phases,
        );

    test('première séance débloque le badge', () {
      final unlocked = newlyUnlockedBadges(stats(sessions: 1), {});
      expect(unlocked.map((b) => b.id), contains('first_session'));
    });

    test('un badge déjà débloqué ne revient pas', () {
      final unlocked =
          newlyUnlockedBadges(stats(sessions: 1), {'first_session'});
      expect(unlocked.map((b) => b.id), isNot(contains('first_session')));
    });

    test('légende exige la phase 4 partout', () {
      expect(
        newlyUnlockedBadges(
                stats(phases: {'a': 4, 'b': 4, 'c': 4, 'd': 3}), {})
            .map((b) => b.id),
        isNot(contains('phase4_all')),
      );
      expect(
        newlyUnlockedBadges(
                stats(phases: {'a': 4, 'b': 4, 'c': 4, 'd': 4}), {})
            .map((b) => b.id),
        contains('phase4_all'),
      );
    });
  });
}
