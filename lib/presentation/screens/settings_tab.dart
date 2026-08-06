import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../domain/content.dart';
import '../../domain/models.dart';

const _weekdays = [
  (1, 'Lun'),
  (2, 'Mar'),
  (3, 'Mer'),
  (4, 'Jeu'),
  (5, 'Ven'),
  (6, 'Sam'),
  (7, 'Dim'),
];

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider)!;
    final notifier = ref.read(profileProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Réglages',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 20),
          const _SectionTitle('Profil'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_rounded),
            title: Text(profile.name),
            subtitle: Text(profile.sex == Sex.male ? 'Homme' : 'Femme'),
            trailing: const Icon(Icons.edit_rounded, size: 20),
            onTap: () => _editProfile(context, notifier, profile),
          ),
          const Divider(),
          const _SectionTitle('Matériel disponible'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in Equipment.values)
                FilterChip(
                  label: Text(e.labelFr),
                  selected: profile.equipment.contains(e),
                  onSelected: (v) {
                    final updated = Set<Equipment>.of(profile.equipment);
                    v ? updated.add(e) : updated.remove(e);
                    notifier.save(profile.copyWith(equipment: updated));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const _SectionTitle('Jours d\'entraînement'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (day, label) in _weekdays)
                FilterChip(
                  label: Text(label),
                  selected: profile.trainingDays.contains(day),
                  onSelected: (v) {
                    final updated = Set<int>.of(profile.trainingDays);
                    v ? updated.add(day) : updated.remove(day);
                    notifier.save(profile.copyWith(trainingDays: updated));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const _SectionTitle('Données'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_forever_rounded, color: scheme.error),
            title: Text('Réinitialiser toute la progression',
                style: TextStyle(color: scheme.error)),
            subtitle: const Text(
                'Efface XP, badges, séries, historique et phases. Irréversible.'),
            onTap: () => _confirmReset(context, ref),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '365 — deviens fit en 365 jours de 20 minutes.\n100 % local : tes données ne quittent jamais ton téléphone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(
      BuildContext context, ProfileController notifier, Profile profile) async {
    final controller = TextEditingController(text: profile.name);
    var sex = profile.sex;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Prénom / pseudo'),
              ),
              const SizedBox(height: 16),
              SegmentedButton<Sex>(
                segments: const [
                  ButtonSegment(value: Sex.male, label: Text('Homme')),
                  ButtonSegment(value: Sex.female, label: Text('Femme')),
                ],
                selected: {sex},
                onSelectionChanged: (s) => setState(() => sex = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
    if (saved == true && controller.text.trim().isNotEmpty) {
      await notifier.save(
          profile.copyWith(name: controller.text.trim(), sex: sex));
    }
    controller.dispose();
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tout réinitialiser ?'),
        content: const Text(
            'Toute ta progression (XP, badges, séries, phases, historique) sera définitivement effacée.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final program = ref.read(programProvider);
      final repo = ref.read(gameRepoProvider);
      await repo.resetAll();
      await repo.ensureProgressRows(program.groups.map((g) => g.id));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );
}
