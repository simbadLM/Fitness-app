import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../domain/gamification.dart';
import '../../domain/models.dart';
import '../theme.dart';

/// Écran de récompense de fin de séance.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.result});

  final SessionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider);
    final scheme = Theme.of(context).colorScheme;
    final levelUp = result.playerLevelAfter > result.playerLevelBefore;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      result.bossWon
                          ? '⚔️ BOSS VAINCU !'
                          : levelUp
                              ? '🎉 Niveau supérieur !'
                              : '💪 Séance terminée !',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: result.xpTotal),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        '+$value XP',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _XpLine('Répétitions', result.xpFromReps),
                          _XpLine('Séance terminée', result.xpCompletionBonus),
                          _XpLine('Bonus de série (${result.streak} j 🔥)',
                              result.xpStreakBonus),
                          if (result.xpBossBonus > 0)
                            _XpLine('Boss vaincu ⚔️', result.xpBossBonus),
                          const Divider(),
                          _XpLine('Total', result.xpTotal, bold: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                            label: 'Tours', value: '${result.rounds}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                            label: 'Répétitions', value: '${result.totalReps}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                            label: 'Durée',
                            value:
                                '${result.duration.inMinutes}:${(result.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
                      ),
                    ],
                  ),
                  for (final entry in result.phaseUps.entries) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.7),
                        ]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_open_rounded,
                              color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Phase ${entry.value} débloquée en ${program.group(entry.key).nameFr} !',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (result.targetUps.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('📈 Objectifs relevés — trop facile pour toi !',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            for (final e in result.targetUps.entries)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '${program.findExercise(e.key)?.name ?? e.key} : '
                                  '${e.value.from} → ${e.value.to}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (result.calibratedTargets.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🧭 Objectifs calibrés',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            for (final e in result.calibratedTargets.entries)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '${program.findExercise(e.key)?.name ?? e.key} : '
                                  'objectif fixé à ${e.value} par tour',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (result.bossGroupId != null && !result.bossWon) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.boss.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Le boss a résisté cette fois… Il t\'attend à la prochaine séance !',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  if (result.newBadges.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Badges débloqués',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    for (final id in result.newBadges)
                      _BadgeTile(
                        badge: Badge.all.firstWhere((b) => b.id == id),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XpLine extends StatelessWidget {
  const _XpLine(this.label, this.xp, {this.bold = false});

  final String label;
  final int xp;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: 15);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text('+$xp', style: style)],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.military_tech_rounded,
            color: AppTheme.gold, size: 32),
        title: Text(badge.title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(badge.description),
      ),
    );
  }
}
