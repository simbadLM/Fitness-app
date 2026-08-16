import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/models.dart';
import '../palettes.dart';
import '../theme.dart';

const _weekdays = [
  (1, 'Lun'),
  (2, 'Mar'),
  (3, 'Mer'),
  (4, 'Jeu'),
  (5, 'Ven'),
  (6, 'Sam'),
  (7, 'Dim'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  Sex? _sex;
  final Set<Equipment> _equipment = {};
  final Set<int> _trainingDays = {1, 2, 4, 5, 6};
  final Map<String, int> _placement = {};
  bool _saving = false;

  /// Placement dans l'arc du voyage, par groupe musculaire.
  static const _placementLevels = [
    (1, 'Apprentissage', 'J\'apprends les mouvements, ma forme casse vite'),
    (2, 'Consolidation', 'Forme correcte, challengé mais capable'),
    (3, 'Athlétisation', 'Je domine, il me faut du lesté ou de l\'explosif'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _valid => _nameController.text.trim().isNotEmpty && _sex != null;

  Future<void> _start() async {
    setState(() => _saving = true);
    final profile = Profile(
      name: _nameController.text.trim(),
      sex: _sex!,
      equipment: Set.of(_equipment),
      trainingDays: Set.of(_trainingDays),
    );
    final program = ref.read(programProvider);
    final repo = ref.read(gameRepoProvider);
    await repo.ensureProgressRows(program.groups.map((g) => g.id));
    for (final group in program.groups) {
      await repo.setPhase(group.id, _placement[group.id] ?? 1);
    }
    await ref.read(profileProvider.notifier).save(profile);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) =>
                  context.colors.gradient.createShader(bounds),
              child: const Text('365',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 64,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
            ),
            const SizedBox(height: 8),
            Text(
              '20 minutes par jour, chez toi.\nDans 365 jours d\'entraînement, tu ne te reconnaîtras plus.',
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            const _SectionTitle('Ton prénom ou pseudo'),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex. : Simon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Ton profil'),
            Row(
              children: [
                Expanded(
                  child: _SexCard(
                    label: 'Homme',
                    icon: Icons.male_rounded,
                    selected: _sex == Sex.male,
                    onTap: () => setState(() => _sex = Sex.male),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SexCard(
                    label: 'Femme',
                    icon: Icons.female_rounded,
                    selected: _sex == Sex.female,
                    onTap: () => setState(() => _sex = Sex.female),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Ton niveau de départ'),
            Text(
              'Sois honnête, l\'app ajustera vite de toute façon. Ta première séance calibrera tes objectifs de répétitions.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            for (final group in ref.watch(programProvider).groups) ...[
              Text(group.nameFr,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              SegmentedButton<int>(
                segments: [
                  for (final (phase, label, _) in _placementLevels)
                    ButtonSegment(
                      value: phase,
                      label: Text(label,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                selected: {_placement[group.id] ?? 1},
                onSelectionChanged: (s) =>
                    setState(() => _placement[group.id] = s.first),
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _placementLevels
                    .firstWhere(
                        (l) => l.$1 == (_placement[group.id] ?? 1))
                    .$3,
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            const _SectionTitle('Ton matériel à la maison'),
            Text('Les exercices proposés s\'adaptent à ce que tu possèdes.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in Equipment.values)
                  FilterChip(
                    label: Text(e.labelFr),
                    selected: _equipment.contains(e),
                    onSelected: (v) => setState(
                        () => v ? _equipment.add(e) : _equipment.remove(e)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Tes jours d\'entraînement'),
            Text(
                'Le guide recommande 5 séances par semaine avec 2 jours de repos. '
                'Les jours de repos ne cassent pas ta série.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (day, label) in _weekdays)
                  FilterChip(
                    label: Text(label),
                    selected: _trainingDays.contains(day),
                    onSelected: (v) => setState(() =>
                        v ? _trainingDays.add(day) : _trainingDays.remove(day)),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _valid && !_saving ? _start : null,
              child: const Text('Commencer le jour 1'),
            ),
            const SizedBox(height: 16),
            Text(
              'Toutes tes données restent sur ton téléphone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      );
}

class _SexCard extends StatelessWidget {
  const _SexCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 40,
                color: selected ? scheme.primary : scheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
