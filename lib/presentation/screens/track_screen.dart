import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/models.dart';
import '../pictograms.dart';
import '../theme.dart';

/// Piste de progression d'un groupe musculaire : les 4 phases et leurs
/// exercices, avec états verrouillé / en cours / terminé.
class TrackScreen extends ConsumerWidget {
  const TrackScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider);
    final profile = ref.watch(profileProvider)!;
    final group = program.group(groupId);
    final progress = ref.watch(progressProvider).value?[groupId] ??
        GroupProgress(groupId: groupId);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(group.nameFr)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (progress.bossStatus == BossStatus.ready)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.boss.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '⚔️ Boss fight disponible ! Lance ta prochaine séance pour tenter de débloquer la phase suivante.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          for (final phaseContent in group.phases) ...[
            _PhaseSection(
              group: group,
              content: phaseContent,
              currentPhase: progress.phase,
              owned: profile.equipment,
            ),
            if (phaseContent.phase < MuscleGroup.maxPhase)
              Center(
                child: Container(
                  width: 3,
                  height: 24,
                  color: phaseContent.phase < progress.phase
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.group,
    required this.content,
    required this.currentPhase,
    required this.owned,
  });

  final MuscleGroup group;
  final PhaseContent content;
  final int currentPhase;
  final Set<Equipment> owned;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final phase = content.phase;
    final done = phase < currentPhase;
    final current = phase == currentPhase;
    final locked = phase > currentPhase;

    return Card(
      color: current
          ? scheme.primaryContainer.withValues(alpha: 0.5)
          : locked
              ? scheme.surfaceContainerLow.withValues(alpha: 0.5)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : current
                          ? Icons.play_circle_fill_rounded
                          : Icons.lock_rounded,
                  color: locked ? scheme.outlineVariant : scheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Phase $phase — ${content.label}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: locked ? scheme.onSurfaceVariant : null,
                  ),
                ),
              ],
            ),
            if (content.rule != null) ...[
              const SizedBox(height: 8),
              Text(
                content.rule!,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
            if (!locked && content.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final exercise in content.exercises)
                _ExerciseTile(exercise: exercise, owned: owned),
            ],
            if (locked && content.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${content.exercises.length} exercices à débloquer en battant le boss de la phase précédente.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.owned});

  final Exercise exercise;
  final Set<Equipment> owned;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final available = exercise.availableWith(owned);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedPictogram(type: exercise.picto, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (exercise.hint != null)
                  Text(exercise.hint!,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (!available)
            Tooltip(
              message:
                  'Matériel requis : ${exercise.equipment.map((e) => e.labelFr).join(' ou ')}',
              child: Icon(Icons.handyman_rounded,
                  size: 18, color: scheme.outlineVariant),
            ),
        ],
      ),
    );
  }
}
