import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/coverage.dart';
import '../../domain/models.dart';
import '../../domain/workout_generator.dart';
import '../palettes.dart';
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
  Map<String, int> _targets = const {};
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
    final now = DateTime.now();
    final progress = await repo.getProgress();
    final targets = await repo.getTargets();
    final lastUsed = await repo.lastUsedByExercise();
    final usageDays =
        await repo.usageDaysSince(now.subtract(const Duration(days: 7)));
    final plan = WorkoutGenerator.generate(
      program: program,
      progress: progress,
      owned: profile.equipment,
      date: now,
      targets: targets,
      lastUsed: lastUsed,
      recentPatternCounts: Coverage.patternDayCounts(usageDays, program),
    );
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _targets = targets;
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

  /// « Fait ✓ » : valide l'objectif tel quel. En calibration (pas d'objectif
  /// connu), la molette s'ouvre pour saisir les répétitions réelles.
  Future<void> _completeSet() async {
    final movement = _current;
    if (movement.isCalibration) {
      return _completeSetAdjusted(
          title: 'Calibration : combien as-tu fait ?');
    }
    _recordSet(movement, movement.effectiveTarget!);
  }

  /// « Ajuster » : saisir un nombre différent de l'objectif.
  Future<void> _completeSetAdjusted({String? title}) async {
    final movement = _current;
    final isDuration = movement.exercise.type == ExerciseType.duration;
    final previous =
        _sets.where((s) => s.exerciseId == movement.exercise.id).toList();
    final initial = previous.isNotEmpty
        ? previous.last.reps
        : movement.effectiveTarget ?? (isDuration ? 30 : 10);
    final reps = await showRepPicker(
      context,
      initial: initial,
      isDuration: isDuration,
      title: title ??
          (movement.isBoss
              ? 'BOSS : objectif ${movement.effectiveTarget} — combien ?'
              : null),
    );
    if (reps == null || !mounted) return;
    _recordSet(movement, reps);
  }

  void _recordSet(Movement movement, int reps) {
    setState(() {
      _sets.add(SetLog(
        exerciseId: movement.exercise.id,
        groupId: movement.group.id,
        phase: movement.phase,
        round: _round,
        reps: reps,
        weighted: movement.weighted,
        isDuration: movement.exercise.type == ExerciseType.duration,
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
              title: Text(e.label),
              subtitle: e.hint != null ? Text(e.hint!) : null,
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
            i == _movementIndex
                ? m.copyWith(
                    exercise: chosen, target: () => _targets[chosen.id])
                : m,
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
      rounds: _round - 1 < 0 ? 0 : _round - 1,
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
          Text('Prochain : ${_current.exercise.label}',
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
    final isDuration = movement.exercise.type == ExerciseType.duration;
    final unit = isDuration ? 's' : 'reps';
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
                '⚔️ BOSS — tiens ${movement.effectiveTarget} $unit sur chaque tour !',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          if (movement.isCalibration)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🧭 Calibration — fais ce que tu tiens proprement sur chaque tour, saisis tes reps',
                style: TextStyle(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          const Spacer(),
          AnimatedPictogram(
            type: movement.exercise.picto,
            size: 180,
            color: movement.isBoss ? AppTheme.boss : null,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  movement.exercise.label,
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
            '${movement.exercise.nameFr != null ? ' · ${movement.exercise.name}' : ''}'
            '${movement.isFocus ? ' · focus' : ''}'
            '${movement.weighted ? ' · avec lest' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          if (movement.exercise.hint != null) ...[
            const SizedBox(height: 8),
            Text(
              movement.exercise.hint!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          if (!movement.isCalibration)
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '${movement.effectiveTarget}',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: movement.isBoss ? AppTheme.boss : scheme.primary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant),
                ),
              ]),
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
                  child: Text(movement.isCalibration
                      ? 'Saisir mes $unit'
                      : 'Fait ✓'),
                ),
              ),
            ],
          ),
          if (!movement.isCalibration)
            TextButton(
              onPressed: () => _completeSetAdjusted(),
              child: Text('J\'ai fait plus ou moins — ajuster',
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant)),
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
                    '${plan.duration.inMinutes} minutes max · objectifs fixes par mouvement — fais un maximum de tours, c\'est ton score. Repos de 10 à 45 s entre les mouvements.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  if (plan.movements.any((m) => m.isCalibration)) ...[
                    const SizedBox(height: 8),
                    Text(
                      '🧭 Certains mouvements sont en calibration : fais ce que tu tiens proprement sur chaque tour et saisis tes reps — l\'app retiendra ton rythme comme objectif.',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
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
                        title: Text(movement.exercise.label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text([
                          movement.group.nameFr,
                          'Phase ${movement.phase}',
                          if (movement.isCalibration)
                            '🧭 calibration'
                          else
                            'objectif ${movement.effectiveTarget} '
                                '${movement.exercise.type == ExerciseType.duration ? 's' : 'reps'}',
                          if (movement.isFocus) 'focus',
                          if (movement.weighted) 'avec lest',
                          if (movement.isBoss) '⚔️ BOSS',
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showWarmup(context),
                          icon: const Icon(Icons.whatshot_rounded, size: 20),
                          label: const Text('Échauffement 2 min'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/method'),
                        child: const Text('Pourquoi ?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('C\'est parti !'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarmup(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _WarmupSheet(),
    );
  }
}

/// Échauffement guidé de 2 minutes : 4 mouvements de 30 s.
class _WarmupSheet extends StatefulWidget {
  const _WarmupSheet();

  @override
  State<_WarmupSheet> createState() => _WarmupSheetState();
}

class _WarmupSheetState extends State<_WarmupSheet> {
  static const _steps = [
    'Cercles de bras + rotations d\'épaules',
    'Montées de genoux sur place',
    'Squats lents à vide, amplitude complète',
    'Charnières de hanche lentes + rotations du buste',
  ];

  Timer? _timer;
  int _remaining = 120;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _timer?.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final index = ((120 - _remaining) ~/ 30).clamp(0, _steps.length - 1);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Échauffement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('30 secondes par mouvement, en douceur.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Text(
              '${(_remaining ~/ 60)}:${(_remaining % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 48,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final (i, step) in _steps.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _timer != null && i < index
                          ? Icons.check_circle_rounded
                          : _timer != null && i == index
                              ? Icons.play_circle_fill_rounded
                              : Icons.circle_outlined,
                      size: 20,
                      color: _timer != null && i <= index
                          ? context.colors.accent
                          : scheme.outlineVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(step,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: _timer != null && i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _timer == null
                  ? _startTimer
                  : () => Navigator.of(context).pop(),
              child: Text(_timer == null ? 'Lancer' : 'Terminer'),
            ),
          ],
        ),
      ),
    );
  }
}
