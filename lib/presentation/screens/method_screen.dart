import 'package:flutter/material.dart';

import '../../domain/content.dart';
import '../../domain/gamification.dart';
import '../palettes.dart';

/// Pédagogie de l'entraînement : chaque mécanisme de l'app expliqué, plus
/// les fondamentaux qui se jouent hors de l'app. Lecture optionnelle.
class MethodScreen extends StatelessWidget {
  const MethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Comprendre la méthode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(
              'Rien n\'est magique dans 365 : chaque mécanisme applique un principe '
              'd\'entraînement connu. Comprendre pourquoi tu fais les choses les rend '
              'plus efficaces — et plus motivantes.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
            ),
          ),
          const _MethodTile(
            icon: Icons.timer_rounded,
            title: 'Pourquoi 20 minutes en circuit ?',
            body:
                'Le format AMRAP (« autant de tours que possible ») condense le travail : '
                'en enchaînant les groupes musculaires, chaque muscle récupère pendant que '
                'les autres travaillent — tu cumules du volume utile sans temps mort. '
                '20 minutes, c\'est le point d\'équilibre entre un stimulus suffisant et '
                'une habitude tenable 5 à 6 jours par semaine. La constance bat '
                'l\'intensité héroïque : une séance courte faite tous les jours construit '
                'plus qu\'une grosse séance abandonnée au bout de trois semaines.',
          ),
          const _MethodTile(
            icon: Icons.adjust_rounded,
            title: 'Objectifs fixes & calibration',
            body:
                'Chaque mouvement a un objectif de répétitions identique à chaque tour. '
                'C\'est ce qui rend ton score (le nombre de tours) comparable d\'une '
                'séance à l\'autre : plus de tours au même objectif = progrès mesuré. '
                'À la première pratique d\'un exercice, tu fais simplement ce que tu '
                'tiens proprement ; l\'app retient la médiane de tes séries — ton rythme '
                'de croisière réel, pas un max qui ruinerait le circuit.',
          ),
          _MethodTile(
            icon: Icons.trending_up_rounded,
            title: 'La progression : +2, maîtrise, boss',
            body:
                'Le principe fondamental est la surcharge progressive : pour progresser, '
                'la demande doit augmenter légèrement et régulièrement. Quand tu tiens '
                'tes objectifs deux séances de suite, l\'app les relève de '
                '+${Gamification.targetIncrementReps} répétitions — un niveau de plus '
                'dans ta phase. Quand un objectif atteint le seuil de maîtrise, le '
                'volume ne suffit plus : il faut un mouvement plus exigeant. C\'est le '
                'boss fight — tenir des objectifs relevés sur toute la séance — qui '
                'débloque la phase suivante et ses variantes plus dures. Les seuils '
                'sont pondérés par la difficulté : maîtriser '
                '${Gamification.masteryRepsByTier[2]} pompes diamant vaut '
                '${Gamification.masteryRepsByTier[0]} pompes à genoux.',
          ),
          const _MethodTile(
            icon: Icons.grid_view_rounded,
            title: 'Les 4 groupes & les phases indépendantes',
            body:
                'Chaque séance touche systématiquement les 4 grands territoires : '
                'bras/pectoraux, jambes, abdominaux, dos — impossible de passer une '
                'semaine en négligeant une zone. Chaque groupe progresse à son rythme : '
                'tu peux être en Athlétisation aux jambes et en Apprentissage au dos, '
                'c\'est normal et voulu. Le focus du jour (lundi bras, mardi jambes, '
                'jeudi abdos, vendredi dos) ajoute du volume là où c\'est le tour.',
          ),
          _MethodTile(
            icon: Icons.hub_rounded,
            title: 'Les schémas moteurs : la vraie exhaustivité',
            bodyWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sous les groupes musculaires, ton corps fonctionne par schémas de '
                  'mouvement. L\'app choisit tes exercices pour visiter, sur 7 jours '
                  'glissants, tous les schémas que ton niveau et ton matériel '
                  'permettent — en privilégiant chaque jour les moins travaillés '
                  'récemment, puis les exercices les moins récents. Ta jauge de '
                  'couverture est dans l\'onglet Stats.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5),
                ),
                const SizedBox(height: 12),
                for (final p in MovementPattern.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: context.colors.accent,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '${p.labelFr} — ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            TextSpan(
                                text: p.hint,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ])),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const _MethodTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Streak & repos : le repos fait partie du plan',
            body:
                'Le muscle se construit pendant la récupération, pas pendant la séance. '
                'Tes jours de repos planifiés ne cassent donc jamais ta série : la '
                'streak mesure ta fidélité au plan, repos compris. Si une séance te '
                'laisse épuisé plusieurs jours, c\'est un signal : réduis d\'un cran '
                '(l\'app ne relève les objectifs que si tu tiens, jamais l\'inverse — '
                'utilise « ajuster » sans complexe les jours difficiles).',
          ),
          const _MethodTile(
            icon: Icons.self_improvement_rounded,
            title: 'Ce qui se joue hors de l\'app (l\'autre moitié du résultat)',
            body:
                '• Échauffement : 2 minutes avant le circuit — articulations, montées de '
                'genoux, premiers mouvements à vide. Le bouton est sur l\'écran de séance.\n'
                '• Cardio doux : 1 à 2 sorties par semaine (marche rapide, vélo, course '
                'facile, 30-45 min en aisance respiratoire) complètent le circuit pour le '
                'cœur et l\'endurance — l\'app ne les remplace pas.\n'
                '• Sommeil : 7 à 9 h. C\'est là que le corps se transforme. Un déficit de '
                'sommeil chronique annule une grande partie du travail.\n'
                '• Nutrition : être « fit visuellement » se joue surtout dans l\'assiette — '
                'suffisamment de protéines (~1,6 g/kg/jour), et un léger déficit ou '
                'surplus calorique selon ton objectif.\n'
                '• Mobilité : garde de l\'amplitude complète sur tes mouvements ; '
                'c\'est la meilleure assurance anti-blessure.',
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Little by little, a little becomes a lot.',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    this.body,
    this.bodyWidget,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? bodyWidget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: context.colors.accent),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          bodyWidget ??
              Text(
                body!,
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: 14, height: 1.5),
              ),
        ],
      ),
    );
  }
}
