import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../data/db.dart';
import '../../domain/gamification.dart';
import '../theme.dart';

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(gameRepoProvider);
    final program = ref.watch(programProvider);
    final player = ref.watch(playerProvider).value;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: StreamBuilder<List<SessionRow>>(
        stream: repo.watchSessions(),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? const <SessionRow>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Statistiques',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                        label: 'Séances', value: '${sessions.length}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        label: 'Meilleure série',
                        value: '${player?.bestStreak ?? 0} j'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        label: 'XP total', value: '${player?.xp ?? 0}'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Répétitions par groupe',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              FutureBuilder<Map<String, int>>(
                future: repo.totalRepsByGroup(),
                builder: (context, repsSnapshot) {
                  final reps = repsSnapshot.data ?? const <String, int>{};
                  final maxReps = reps.values.isEmpty
                      ? 1
                      : reps.values.reduce((a, b) => a > b ? a : b);
                  return Column(
                    children: [
                      for (final group in program.groups)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(group.nameFr,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: (reps[group.id] ?? 0) /
                                        (maxReps == 0 ? 1 : maxReps),
                                    minHeight: 10,
                                    backgroundColor:
                                        scheme.surfaceContainerHighest,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 48,
                                child: Text('${reps[group.id] ?? 0}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Badges',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final badge in Badge.all)
                    Tooltip(
                      message: badge.description,
                      child: Chip(
                        avatar: Icon(
                          Icons.military_tech_rounded,
                          size: 18,
                          color: (player?.badges.contains(badge.id) ?? false)
                              ? AppTheme.gold
                              : scheme.outlineVariant,
                        ),
                        label: Text(
                          badge.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: (player?.badges.contains(badge.id) ?? false)
                                ? null
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Historique',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (sessions.isEmpty)
                Text('Aucune séance pour l\'instant — lance ta première quête !',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              for (final s in sessions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    s.bossGroupId != null && s.bossWon
                        ? Icons.sports_mma_rounded
                        : Icons.check_circle_rounded,
                    color: s.bossGroupId != null && s.bossWon
                        ? AppTheme.boss
                        : scheme.primary,
                  ),
                  title: Text(
                    '${s.date.day.toString().padLeft(2, '0')}/${s.date.month.toString().padLeft(2, '0')}/${s.date.year}'
                    '${s.bossWon ? ' · boss vaincu ⚔️' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                      '${s.rounds} tours · ${(s.durationSeconds / 60).round()} min'),
                  trailing: Text('+${s.xp} XP',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: scheme.primary)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
