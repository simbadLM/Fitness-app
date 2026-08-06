import 'package:flutter/material.dart';

import '../domain/gamification.dart';
import 'theme.dart';

/// Barre d'XP du joueur avec niveau.
class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final info = Gamification.levelInfo(xp);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Niveau ${info.level}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('${info.inLevel} / ${info.forNext} XP',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: info.inLevel / info.forNext),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compteur de streak avec flamme.
class StreakFlame extends StatelessWidget {
  const StreakFlame({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.gold.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              size: 20,
              color: active ? const Color(0xFFE8590C) : Colors.grey),
          const SizedBox(width: 4),
          Text('$streak',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}

/// Pastille de phase (1–4) d'un groupe musculaire.
class PhasePill extends StatelessWidget {
  const PhasePill({super.key, required this.phase, required this.label});

  final int phase;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Sélecteur de répétitions : molette + boutons +/-.
/// Retourne la valeur choisie, ou null si annulé.
Future<int?> showRepPicker(
  BuildContext context, {
  required int initial,
  required bool isDuration,
  String? title,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => _RepPickerSheet(
      initial: initial,
      isDuration: isDuration,
      title: title,
    ),
  );
}

class _RepPickerSheet extends StatefulWidget {
  const _RepPickerSheet({
    required this.initial,
    required this.isDuration,
    this.title,
  });

  final int initial;
  final bool isDuration;
  final String? title;

  @override
  State<_RepPickerSheet> createState() => _RepPickerSheetState();
}

class _RepPickerSheetState extends State<_RepPickerSheet> {
  static const _maxReps = 100;
  static const _maxSeconds = 300;

  late final int _step = widget.isDuration ? 5 : 1;
  late final int _max = widget.isDuration ? _maxSeconds : _maxReps;
  late int _value = widget.initial.clamp(0, _max);
  late final FixedExtentScrollController _wheel =
      FixedExtentScrollController(initialItem: _value ~/ _step);

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  void _set(int value) {
    final clamped = value.clamp(0, _max);
    setState(() => _value = clamped);
    _wheel.jumpToItem(clamped ~/ _step);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unit = widget.isDuration ? 's' : 'reps';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title ?? 'Combien de $unit ?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: () => _set(_value - _step),
                  icon: const Icon(Icons.remove_rounded),
                  iconSize: 32,
                ),
                SizedBox(
                  width: 120,
                  height: 160,
                  child: ListWheelScrollView.useDelegate(
                    controller: _wheel,
                    itemExtent: 48,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (i) =>
                        setState(() => _value = i * _step),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _max ~/ _step + 1,
                      builder: (context, i) {
                        final v = i * _step;
                        final selected = v == _value;
                        return Center(
                          child: Text(
                            '$v',
                            style: TextStyle(
                              fontSize: selected ? 32 : 22,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: selected
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _set(_value + _step),
                  icon: const Icon(Icons.add_rounded),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_value),
              child: Text('Valider · $_value $unit'),
            ),
          ],
        ),
      ),
    );
  }
}
