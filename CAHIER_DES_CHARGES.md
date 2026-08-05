# Cahier des charges — Application sportive gamifiée (Android)

> **Version 0.2** — le guide PDF a été analysé ; le contenu est extrait dans
> `content/program.json` (source : `docs/DailyRepsGuy-Workout-Guide.pdf`).

## 1. Vision

Transformer le guide **DailyRepsGuy — "How to Get Jacked in Under 20 Minutes a
Day"** en application Android interactive et gamifiée : des séances de 20 minutes
maximum, à la maison, avec une progression par phases qui se débloque comme dans
un jeu.

## 2. Décisions actées

| Sujet | Décision |
|---|---|
| Plateforme | Android (Flutter → portage iOS possible) |
| Stack | **Flutter (Dart)** |
| Persistance | **100 % local, sans compte** (drift/SQLite + préférences) |
| Gamification | **Niveaux + XP + badges + streaks** |
| Profil | Homme / femme dès l'onboarding |
| Contenu | Guide DailyRepsGuy, versionné en JSON dans les assets |

## 3. Analyse du guide (synthèse)

Le guide ne définit **pas un programme linéaire de séances** mais une **méthode** :

- **4 groupes musculaires** : Bras & Pectoraux, Jambes, Abdominaux, Dos.
- **4 phases par groupe** : Beginner, Intermediate, Advanced, Pro (= Advanced
  avec du lest). Chaque phase liste 4 à 9 exercices réalisables à la maison
  (poids du corps, kettlebell, sac à dos, chaise).
- **La phase est indépendante par groupe musculaire** : on peut être Phase 3
  jambes et Phase 1 dos — l'app doit gérer 4 curseurs de progression distincts.
- **Format de séance** : circuit AMRAP de 20 min max — 1 exercice par groupe
  (dans sa phase courante) + 1–2 exercices "focus" sur un groupe du jour
  (5–6 mouvements au total), repos 10–45 s entre mouvements, autant de tours
  que possible.
- **Règles de progression** (à automatiser dans l'app) :
  - *Rule of thumb* : +2 répétitions sur la dernière série pendant 2 séances
    consécutives → proposer la phase supérieure ;
  - +10–20 % de répétitions totales à durée égale → durcir la séance ;
  - micro-progressions avant de changer de phase : tempo, pauses, lest,
    volume, amplitude.
- **Semaine type** : 5–6 séances avec rotation du focus (lun. bras/pecs,
  mar. jambes, jeu. abdos, ven. dos, sam. libre), repos mercredi et dimanche.
- Le guide insiste sur la **constance** ("keep stacking daily wins") et
  l'**accountability** → cœur de la gamification (streaks, badges).
- Le guide est **unisexe** : le choix homme/femme du profil n'affecte pas le
  contenu ; il sert à la personnalisation (avatar, formulations, et
  éventuellement statistiques futures).

## 4. Transposition en jeu (proposition)

### 4.1 Quatre pistes de progression ("skill tracks")
Chaque groupe musculaire est une piste visuelle de 4 niveaux (phases). La phase
N+1 est **verrouillée** tant que les critères de progression ne sont pas
atteints ; l'app détecte automatiquement le déclencheur (*rule of thumb* sur les
répétitions enregistrées) et propose un "combat de boss" : une séance test qui,
réussie, débloque la phase avec animation de récompense.

### 4.2 La séance quotidienne ("quête du jour")
L'app génère le circuit du jour selon la méthode du guide : 1 exercice par
groupe tiré de la phase courante + focus du jour (rotation hebdomadaire),
minuteur 20 min, compteur de tours et de répétitions, repos chronométré 10–45 s.
L'utilisateur peut échanger un exercice proposé contre un autre de la même phase.

### 4.3 Économie d'XP
- XP par répétition validée + bonus de fin de séance + bonus de streak.
- Niveau de joueur global (distinct des phases) avec seuils croissants.
- Badges : première séance, 7/30/100 jours de streak, phase débloquée,
  record de tours battu, groupe au niveau Pro, etc.
- **Streak compatible avec les jours de repos** : le guide prescrit 2 jours de
  repos/semaine → la série n'est pas cassée par un jour de repos planifié.

### 4.4 Statistiques
Historique des séances, répétitions totales par groupe, graphique de
progression (le signal +10–20 % du guide devient une jauge visible), records.

## 5. Architecture technique (niveau ingénieur)

### 5.1 Stack
- **Flutter** stable (Dart 3), Android `minSdk 26`.
- **État** : Riverpod. **Navigation** : `go_router`.
- **Persistance** : `drift` (SQLite typé) pour séances/records/progression ;
  `shared_preferences` pour profil et réglages.
- **Tests** : unitaires sur le moteur de progression et l'économie d'XP
  (fonctions pures), widget tests, golden tests écrans clés.
- **CI** : GitHub Actions — `flutter analyze` + `flutter test` + build APK.

### 5.2 Découpage en couches
```
presentation/   écrans, widgets, animations (dépend de domain)
domain/         entités, use cases, moteur de gamification (pur Dart, 100 % testable)
data/           repositories, drift, préférences (implémente les interfaces de domain)
content/        program.json — catalogue exercices/phases extrait du guide
```

### 5.3 Modèle de données
- `Profile` (pseudo, sexe, jours d'entraînement, matériel disponible)
- `MuscleGroup` → `Phase` → `Exercise` (statique, depuis `content/program.json`)
- `ProgressState` : phase courante **par groupe musculaire** (4 curseurs)
- `WorkoutSession` (date, durée, exercices, tours, répétitions par exercice)
- `PlayerState` (XP total, niveau joueur, badges, streak courant/max)
- Moteur : `phaseUpEligibility(records)`, `xpFor(session)`, `streak(records,
  restDays)` — fonctions pures testées unitairement.

## 6. Questions ouvertes

1. **Comptage des répétitions** : saisie manuelle par tap pendant le circuit
   (un gros bouton par tour/exercice), ou saisie récapitulative en fin de
   séance ? Le tap en direct est plus "jeu" mais plus contraignant.
2. **Déblocage de phase** : automatique dès critères atteints, ou via une
   "séance de validation" (boss fight) ? (Proposition : boss fight.)
3. **Matériel** : filtrer les exercices selon le matériel déclaré dans le
   profil (kettlebell, barre de traction, chaise…) ?
4. **Notifications** : rappels quotidiens + alerte "streak en danger" ?
5. **Direction artistique** : univers graphique et nom de l'application.
6. **Illustrations d'exercices** : pictogrammes/animations à produire, ou
   texte descriptif seul pour la v1 ?
