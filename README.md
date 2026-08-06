# 365

**Deviens fit en 365 jours d'entraînement de 20 minutes par jour.**

Application Android & iOS (Flutter). Chaque jour, un circuit de 20 minutes à
la maison ; chaque séance fait avancer ton compteur — **Jour N / 365** — vers
la meilleure version de toi-même. La progression est un voyage en trois arcs :

1. **Apprentissage · Reprise** — on apprend les gestes, on retrouve son corps.
2. **Consolidation** — l'habitude s'installe, la forme revient.
3. **Athlétisation** — le corps devient athlète *(puis l'arc **Maîtrise**,
   sous charge)*.

Cahier des charges : [`CAHIER_DES_CHARGES.md`](CAHIER_DES_CHARGES.md).

## Fonctionnalités

- **Jour N / 365** en héros de l'accueil, avec timeline projetée des arcs.
- **Quête du jour** : circuit AMRAP — 1 exercice par groupe musculaire
  (Bras/Pecs, Jambes, Abdos, Dos) + focus du jour, objectifs de répétitions
  fixes, **le score = le nombre de tours**.
- **Placement & calibration** : quiz de niveau à l'onboarding, puis la
  première pratique de chaque exercice calibre ton objectif (médiane des
  séries que tu tiens réellement en circuit).
- **Progression organique** : objectifs tenus 2 séances de suite → +2 reps
  (niveau suivant dans l'arc) ; au seuil de maîtrise → **boss fight** à
  objectifs relevés → arc suivant débloqué. Phases indépendantes par groupe.
- **XP, niveaux, badges, streak** respectant les jours de repos planifiés.
- **Matériel** : exercices filtrés selon ce que tu possèdes.
- **Pictogrammes animés** vectoriels avec accessoires dessinés.
- **Design sport / gaming** : fond bleu nuit, gradient turquoise → bleu
  électrique, typo athlétique Rajdhani.
- **100 % local** : profil et historique (SQLite/drift) sur l'appareil.

## Architecture

```
lib/
  domain/        modèles + moteur de gamification + générateur + voyage 365
                 (Dart pur, testé unitairement)
  data/          base drift (SQLite), dépôts, service de fin de séance
  presentation/  écrans, thème, pictogrammes animés (CustomPainter)
content/
  program.json   catalogue exercices/phases (source de vérité du contenu)
assets/icon/     logo 365 (généré, décliné via flutter_launcher_icons)
fonts/           Rajdhani
```

## Développement

```bash
flutter pub get
dart run build_runner build   # génération drift (db.g.dart)
flutter analyze
flutter test
flutter run                   # sur un appareil/émulateur
flutter build apk --release   # APK Android installable
```

## Builds sans installation locale

Chaque push déclenche la CI GitHub Actions (analyse + tests + builds). Les
binaires sont publiés en **artefacts** du workflow : onglet *Actions* →
dernier run → *Artifacts*.

### Android — `fitness-game-apk`
APK release directement installable (autoriser les sources inconnues).

### iOS — `fitness-game-ios-unsigned-ipa`
IPA compilé sur un runner macOS mais **non signé** (Apple exige une signature
pour installer une app). Options d'installation sur iPhone :

1. **Sideloading avec un identifiant Apple gratuit** : outils comme
   [Sideloadly](https://sideloadly.io) ou [AltStore](https://altstore.io)
   signent l'IPA avec votre Apple ID et l'installent depuis un PC/Mac.
   Limite du compte gratuit : l'app expire au bout de 7 jours (ré-installation
   en un clic), 3 apps maximum.
2. **Compte Apple Developer (99 $/an)** : signature durable, distribution
   TestFlight ou App Store.
3. **Xcode sur Mac** : brancher l'iPhone et `flutter run --release`.
