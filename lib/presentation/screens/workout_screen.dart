import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/models.dart';
import '../../domain/workout_generator.dart';
import '../pictograms.dart';
import '../theme.dart';
import '../widgets.dart';

enum _Stage { loading, preview, exercising, resting, finished }

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  _Stage _stage = _Stage.loading;
  WorkoutPlan? _plan;
  Timer? _ticker;

  late int _remainingSeconds;
  int _restRemaining = 0;
  int _movementIndex = 0;
  int _round = 1;
  final List<SetLog> _sets = [];
  bool _saving = false;

  static const _restSeconds = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final program = ref.read(programProvider);
    final profile = ref.read(profileProvider)!;
    final repo = ref.read(gameRepoProvider);
    await repo.ensureProgressRows(program.groups.map((g) => g.id));
    final progress = await repo.getProgress();
    final lastReps = await repo.lastSetRepsByExercise();
    final plan = WorkoutGenerator.generate(
      program: program,
      progress: progress,
      owned: profile.equipment,
      date: DateTime.now(),
      lastSetReps: lastReps,
    );
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _remainingSeconds = plan.duration.inSeconds;
      _stage = _Stage.preview;
    });
  }

  void _start() {
    setState(() => _stage = _Stage.exercising);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _remainingSeconds--;
      if (_stage == _Stage.resting && _restRemaining > 0) {
        _restRemaining--;
        if (_restRemaining == 0) _stage = _Stage.exercising;
      }
    });
    if (_remainingSeconds <= 0) {
      _ticker?.cancel();
      _onTimeUp();
    }
  }

  Future<void> _onTimeUp() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏱ Temps écoulé !'),
        content: const Text(
            'Les 20 minutes sont terminées. Bien joué, on compte les points !'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voir mes récompenses'),
          ),
        ],
      ),
    );
    await _finish();
  }

  Movement get _current => _plan!.movements[_movementIndex];

  Future<void> _completeSet() async {
    final movement = _current;
    final isDuration = movement.exercise.type == ExerciseType.duration;
    final previous = _sets
        .where((s) => s.exerciseId == movement.exercise.id)
        .toList();
    final initial = previous.isNotEmpty
        ? previous.last.reps
        : movement.suggestedReps ?? (isDuration ? 30 : 10);
    final reps = await showRepPicker(
      context,
      initial: initial,
      isDuration: isDuration,
      title: movement.isBoss
          ? 'BOSS : objectif ${movement.bossTarget} — combien de reps ?'
          : null,
    );
    if (reps == null || !mounted) return;
    setState(() {
      _sets.add(SetLog(
        exerciseId: movement.exercise.id,
        groupId: movement.group.id,
        phase: movement.phase,
        round: _round,
        reps: reps,
        weighted: movement.weighted,
        isDuration: isDuration,
      ));
      if (_movementIndex == _plan!.movements.length - 1) {
        _movementIndex = 0;
        _round++;
      } else {
        _movementIndex++;
      }
      if (_remainingSeconds > _restSeconds) {
        _stage = _Stage.resting;
        _restRemaining = _restSeconds;
      }
    });
  }

  void _swapExercise() async {
    final profile = ref.read(profileProvider)!;
    final movement = _current;
    final options = WorkoutGenerator.alternatives(
        movement: movement, owned: profile.equipment);
    if (options.isEmpty) return;
    final chosen = await showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          for (final e in options)
            ListTile(
              leading: AnimatedPictogram(type: e.picto, size: 40),
              title: Text(e.name),
              subtitle: e.note != null ? Text(e.note!) : null,
              onTap: () => Navigator.of(context).pop(e),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _plan = WorkoutPlan(
        movements: [
          for (final (i, m) in _plan!.movements.indexed)
            i == _movementIndex ? m.copyWith(exercise: chosen) : m,
        ],
        focusGroupId: _plan!.focusGroupId,
        bossGroupId: _plan!.bossGroupId,
        duration: _plan!.duration,
      );
    });
  }

  Future<void> _finish() async {
    if (_saving || _plan == null) return;
    if (_sets.isEmpty) {
      if (mounted) context.pop();
      return;
    }
    setState(() {
      _saving = true;
      _stage = _Stage.finished;
    });
    _ticker?.cancel();
    final service = ref.read(workoutServiceProvider);
    final profile = ref.read(profileProvider)!;
    final elapsed =
        Duration(seconds: _plan!.duration.inSeconds - _remainingSeconds);
    final result = await service.completeSession(
      plan: _plan!,
      sets: _sets,
      elapsed: elapsed,
      rounds: _round - 1 >= 1 ? _round - (_movementIndex == 0 ? 1 : 0) : _round,
      profile: profile,
    );
    if (!mounted) return;
    context.pushReplacement('/summary', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.loading ||
      _Stage.finished =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      _Stage.preview => _PreviewView(
          plan: _plan!,
          onStart: _start,
          onSwap: (index) {
            _movementIndex = index;
            _swapExercise();
            _movementIndex = 0;
          },
        ),
      _Stage.exercising || _Stage.resting => _buildRun(context),
    };
  }

  Widget _buildRun(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final movement = _current;
    final resting = _stage == _Stage.resting;
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text('$minutes:$seconds',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: _remainingSeconds < 60 ? AppTheme.boss : null,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text('Tour $_round',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          TextButton(onPressed: _finish, child: const Text('Terminer')),
        ],
      ),
      body: SafeArea(
        child: resting ? _buildRest(scheme) : _buildExercise(scheme, movement),
      ),
    );
  }

  Widget _buildRest(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Repos', style: TextStyle(fontSize: 22, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Text('$_restRemaining',
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Prochain : ${_current.exercise.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => setState(() {
              _restRemaining = 0;
              _stage = _Stage.exercising;
            }),
            child: const Text('Passer le repos'),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise(ColorScheme scheme, Movement movement) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (movement.isBoss)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.boss,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⚔️ BOSS — fais ${movement.bossTarget} reps sur une série !',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          const Spacer(),
          AnimatedPictogram(
            type: movement.exercise.picto,
            size: 200,
            color: movement.isBoss ? AppTheme.boss : null,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  movement.exercise.name,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              if (movement.weighted)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.fitness_center_rounded, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${movement.group.nameFr}'
            '${movement.isFocus ? ' · focus' : ''}'
            '${movement.weighted ? ' · avec lest' : ''}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          if (movement.exercise.note != null) ...[
            const SizedBox(height: 8),
            Text(
              movement.exercise.note!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            movement.exercise.type == ExerciseType.duration
                ? 'Objectif : ~${movement.suggestedReps ?? 30} s'
                : 'Objectif : ~${movement.suggestedReps ?? 10} reps',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _swapExercise,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Changer'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _completeSet,
                  style: movement.isBoss
                      ? FilledButton.styleFrom(backgroundColor: AppTheme.boss)
                      : null,
                  child: const Text('Série faite ✓'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({
    required this.plan,
    required this.onStart,
    required this.onSwap,
  });

  final WorkoutPlan plan;
  final VoidCallback onStart;
  final ValueChanged<int> onSwap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Quête du jour')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    '${plan.duration.inMinutes} minutes max · circuit — enchaîne les mouvements et fais un maximum de tours. Repos de 10 à 45 s entre les mouvements.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  for (final (index, movement) in plan.movements.indexed)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: movement.isBoss
                          ? AppTheme.boss.withValues(alpha: 0.1)
                          : null,
                      child: ListTile(
                        leading: AnimatedPictogram(
                            type: movement.exercise.picto, size: 44),
                        title: Text(movement.exercise.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text([
                          movement.group.nameFr,
                          'Phase ${movement.phase}',
                          if (movement.isFocus) 'focus',
                          if (movement.weighted) 'avec lest',
                          if (movement.isBoss)
                            '⚔️ BOSS · objectif ${movement.bossTarget} reps',
                        ].join(' · ')),
                        trailing: IconButton(
                          icon: const Icon(Icons.swap_horiz_rounded),
                          onPressed: () => onSwap(index),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('C\'est parti !'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
