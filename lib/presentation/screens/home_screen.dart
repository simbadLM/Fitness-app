import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/gamification.dart';
import '../../domain/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'settings_tab.dart';
import 'stats_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [_HomeTab(), StatsTab(), SettingsTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.sports_gymnastics_rounded), label: 'Entraînement'),
          NavigationDestination(
              icon: Icon(Icons.insights_rounded), label: 'Stats'),
          NavigationDestination(
              icon: Icon(Icons.settings_rounded), label: 'Réglages'),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider);
    final profile = ref.watch(profileProvider)!;
    final player = ref.watch(playerProvider).value;
    final progress = ref.watch(progressProvider).value ?? {};
    final scheme = Theme.of(context).colorScheme;

    final today = DateTime.now();
    final isTrainingDay = profile.trainingDays.contains(today.weekday);
    final trainedToday = player?.lastTrainingDay != null &&
        DateUtils.isSameDay(player!.lastTrainingDay, today);
    final streak = player == null
        ? 0
        : Gamification.currentStreak(
            stored: player.streak,
            lastTrainingDay: player.lastTrainingDay,
            today: today,
            trainingDays: profile.trainingDays,
          );
    final bossGroups = [
      for (final g in program.groups)
        if ((progress[g.id]?.bossStatus ?? BossStatus.normal) != BossStatus.normal)
          (g, progress[g.id]!.bossStatus),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Salut ${profile.name} !',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StreakFlame(streak: streak),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: XpBar(xp: player?.xp ?? 0),
            ),
          ),
          const SizedBox(height: 20),
          _QuestCard(
            isTrainingDay: isTrainingDay,
            trainedToday: trainedToday,
            hasBoss: bossGroups.any((b) => b.$2 == BossStatus.ready),
          ),
          for (final (group, status) in bossGroups) ...[
            const SizedBox(height: 12),
            _BossBanner(group: group, status: status),
          ],
          const SizedBox(height: 24),
          const Text('Tes pistes de progression',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final group in program.groups) ...[
            _TrackCard(
              group: group,
              progress: progress[group.id] ?? GroupProgress(groupId: group.id),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Méthode DailyRepsGuy — circuits de 20 min max.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.isTrainingDay,
    required this.trainedToday,
    required this.hasBoss,
  });

  final bool isTrainingDay;
  final bool trainedToday;
  final bool hasBoss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = trainedToday
        ? 'Séance du jour déjà terminée. Tu peux en refaire une !'
        : isTrainingDay
            ? 'Circuit de 20 minutes max. Autant de tours que possible !'
            : 'Jour de repos planifié — mais rien ne t\'arrête.';
    return Material(
      color: hasBoss ? AppTheme.boss : scheme.primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.push('/workout'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                hasBoss ? Icons.sports_mma_rounded : Icons.bolt_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasBoss ? 'BOSS FIGHT !' : 'Quête du jour',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _BossBanner extends StatelessWidget {
  const _BossBanner({required this.group, required this.status});

  final MuscleGroup group;
  final BossStatus status;

  @override
  Widget build(BuildContext context) {
    final ready = status == BossStatus.ready;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.boss.withValues(alpha: ready ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.boss.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(ready ? Icons.sports_mma_rounded : Icons.radar_rounded,
              color: AppTheme.boss),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ready
                  ? 'Boss prêt en ${group.nameFr} : bats ton record pour débloquer la phase suivante !'
                  : 'Boss en approche en ${group.nameFr} — encore une amélioration !',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.group, required this.progress});

  final MuscleGroup group;
  final GroupProgress progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: () => context.push('/track/${group.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.nameFr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var p = 1; p <= MuscleGroup.maxPhase; p++) ...[
                          _PhaseDot(
                            state: p < progress.phase
                                ? _DotState.done
                                : p == progress.phase
                                    ? _DotState.current
                                    : _DotState.locked,
                          ),
                          if (p < MuscleGroup.maxPhase)
                            Container(
                              width: 24,
                              height: 3,
                              color: p < progress.phase
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                            ),
                        ],
                        const SizedBox(width: 12),
                        PhasePill(
                          phase: progress.phase,
                          label: group.phaseLabel(progress.phase),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DotState { done, current, locked }

class _PhaseDot extends StatelessWidget {
  const _PhaseDot({required this.state});

  final _DotState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (state) {
      _DotState.done => Icon(Icons.check_circle_rounded,
          size: 22, color: scheme.primary),
      _DotState.current => Icon(Icons.radio_button_checked_rounded,
          size: 22, color: scheme.primary),
      _DotState.locked => Icon(Icons.lock_rounded,
          size: 18, color: scheme.outlineVariant),
    };
  }
}
