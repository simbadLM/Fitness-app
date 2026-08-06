# Fitness Game 🏋️

Application Android & iOS (Flutter) qui transforme le guide **DailyRepsGuy —
"How to Get Jacked in Under 20 Minutes a Day"** en jeu : circuits de 20 minutes
à la maison, progression par phases qui se débloquent en battant des **boss**,
XP, badges et série de jours (streak).

Cahier des charges complet : [`CAHIER_DES_CHARGES.md`](CAHIER_DES_CHARGES.md).
Guide source : [`docs/DailyRepsGuy-Workout-Guide.pdf`](docs/DailyRepsGuy-Workout-Guide.pdf).

## Fonctionnalités

- **Quête du jour** : circuit AMRAP généré selon la méthode du guide —
  1 exercice par groupe musculaire (Bras/Pecs, Jambes, Abdos, Dos) dans sa
  phase courante + exercice focus du jour, minuteur 20 min, repos chronométré.
- **4 pistes de progression indépendantes** : chaque groupe musculaire a sa
  phase (Beginner → Intermediate → Advanced → Pro).
- **Boss fights automatiques** : la *rule of thumb* du guide (+2 reps sur la
  dernière série, 2 séances de suite) est détectée par l'app, qui annonce le
  boss à l'avance ; le vaincre débloque la phase suivante.
- **Saisie des répétitions à chaque série** : molette + incrément/décrément,
  préremplie avec la dernière performance.
- **Matériel** : les exercices proposés s'adaptent au matériel déclaré
  (kettlebell, barre de traction, chaise, sac à dos…).
- **Pictogrammes animés** dessinés en vectoriel (aucune image embarquée).
- **XP, niveaux, badges, streak** compatible avec les jours de repos planifiés.
- **100 % local** : profil dans les préférences, historique dans SQLite (drift).
  Aucune donnée ne quitte le téléphone.

## Architecture

```
lib/
  domain/        modèles + moteur de gamification + générateur de séances
                 (Dart pur, testé unitairement)
  data/          base drift (SQLite), dépôts, service de fin de séance
  presentation/  écrans, thème Material 3, pictogrammes animés (CustomPainter)
content/
  program.json   catalogue exercices/phases extrait du guide (source de vérité)
```

## Développement

```bash
flutter pub get
dart run build_runner build   # génération drift (db.g.dart)
flutter analyze
flutter test
flutter run                   # sur un appareil/émulateur Android
flutter build apk --release   # APK installable
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
   TestFlight ou App Store. Le build local se fait alors sur Mac :
   `flutter build ipa` puis upload via Xcode/Transporter.
3. **Xcode sur Mac** : brancher l'iPhone et `flutter run --release`
   (signature développeur automatique, expire en 7 jours avec un compte
   gratuit).
