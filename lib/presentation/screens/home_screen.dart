import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/gamification.dart';
import '../../domain/journey.dart';
import '../../domain/models.dart';
import '../palettes.dart';
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

    final dayNumber = ref.watch(dayNumberProvider).value ?? 0;
    final arc = Journey.currentArc(progress.values);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    context.colors.gradient.createShader(bounds),
                child: const Text('365',
                    style: TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 36,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.push('/method'),
                    tooltip: 'Comprendre la méthode',
                    icon: Icon(Icons.school_rounded,
                        color: scheme.onSurfaceVariant),
                  ),
                  StreakFlame(streak: streak),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bonjour ${profile.name}.',
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _DayHero(dayNumber: dayNumber, arc: arc),
          const SizedBox(height: 14),
          _JourneyTimeline(dayNumber: dayNumber, arc: arc),
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
          const SectionLabel('Progression'),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: XpBar(xp: player?.xp ?? 0),
            ),
          ),
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
              '20 minutes par jour. 365 jours. Ta meilleure version.',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le héros du voyage : « Jour N / 365 ».
class _DayHero extends StatelessWidget {
  const _DayHero({required this.dayNumber, required this.arc});

  final int dayNumber;
  final int arc;

  @override
  Widget build(BuildContext context) {
    final remaining = (Journey.totalDays - dayNumber).clamp(0, Journey.totalDays);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C1B36), Color(0xFF0A2E4E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: context.colors.accent.withValues(alpha: 0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: context.colors.accentB.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('JOUR',
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
                color: AppTheme.blanc.withValues(alpha: 0.7),
              )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    context.colors.gradient.createShader(bounds),
                child: Text('$dayNumber',
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 72,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
              const SizedBox(width: 8),
              Text('/ 365',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 26,
                    color: AppTheme.blanc.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dayNumber == 0
                ? 'Le voyage commence aujourd\'hui.'
                : 'Rendez-vous dans $remaining jours avec ta meilleure version.',
            style: TextStyle(
                fontSize: 13, color: AppTheme.blanc.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(
                    height: 6, color: AppTheme.blanc.withValues(alpha: 0.12)),
                FractionallySizedBox(
                  widthFactor:
                      (dayNumber / Journey.totalDays).clamp(0.004, 1.0),
                  child: Container(
                    height: 6,
                    decoration:
                        BoxDecoration(gradient: context.colors.gradient),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline projetée des arcs du voyage, avec le marqueur « tu es ici ».
class _JourneyTimeline extends StatelessWidget {
  const _JourneyTimeline({required this.dayNumber, required this.arc});

  final int dayNumber;
  final int arc;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final segments = Journey.segments(arc);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    Journey.arcNames[arc]!,
                    style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Text('acte ${arc - segments.first.arc + 1}/${segments.length}',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 2),
            Text(Journey.arcMottos[arc]!,
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                // Marqueur toujours contenu dans la carte, même au jour 0 ou 365.
                final x = (dayNumber / Journey.totalDays * w)
                    .clamp(6.0, w - 6.0)
                    .toDouble();
                return SizedBox(
                  height: 26,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            for (final s in segments) ...[
                              Expanded(
                                flex: s.endDay - s.startDay,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: s.arc < arc
                                        ? context.colors.accent
                                        : s.arc == arc
                                            ? context.colors.accent
                                                .withValues(alpha: 0.55)
                                            : scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              if (s != segments.last) const SizedBox(width: 3),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        left: x - 5,
                        top: 3,
                        child: Container(
                          width: 10,
                          height: 18,
                          decoration: BoxDecoration(
                            color: scheme.onSurface,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: context.colors.accent, width: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final s in segments)
                  Text(s.name.split(' ').first,
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.5,
                          color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
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
    final subtitle = trainedToday
        ? 'Séance du jour déjà terminée. Tu peux en refaire une !'
        : isTrainingDay
            ? 'Circuit de 20 minutes max. Autant de tours que possible !'
            : 'Jour de repos planifié — mais rien ne t\'arrête.';
    return Container(
      decoration: BoxDecoration(
        gradient:
            hasBoss ? context.colors.bossGradient : context.colors.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (hasBoss ? AppTheme.carmin : context.colors.accent)
                .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/workout'),
        borderRadius: BorderRadius.circular(20),
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
                      hasBoss ? 'BOSS FIGHT !' : 'QUÊTE DU JOUR',
                      style: const TextStyle(
                          fontFamily: AppTheme.displayFont,
                          color: Colors.white,
                          fontSize: 23,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700),
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
                  ? 'Boss prêt en ${group.nameFr} : tiens les objectifs relevés (+2) pour débloquer la phase suivante !'
                  : 'Boss en approche en ${group.nameFr} — encore une séance à l\'objectif !',
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
                            Expanded(
                              child: Container(
                                height: 3,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                color: p < progress.phase
                                    ? scheme.primary
                                    : scheme.surfaceContainerHighest,
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: PhasePill(
                            phase: progress.phase,
                            label:
                                '${group.phaseLabel(progress.phase)} · Niv. ${progress.levelInPhase}',
                          ),
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
