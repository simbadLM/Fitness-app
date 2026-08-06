# Cahier des charges — 365 (Android & iOS)

> **Version 2.0 « 365 »** — rebranding et concept produit finalisés.
> Contenu d'entraînement dans `content/program.json`.

## 1. Vision

**365** : deviens fit en 365 jours d'entraînement de 20 minutes par jour.
L'app matérialise le voyage — le numéro du jour (Jour N / 365) est le héros de
l'accueil — avec une progression par arcs qui se débloquent comme dans un jeu :
**Apprentissage · Reprise** → **Consolidation** → **Athlétisation** (puis
**Maîtrise**, sous charge), chacun contenant des niveaux (+2 répétitions).

## 2. Décisions actées

| Sujet | Décision |
|---|---|
| Plateforme | Android (Flutter → portage iOS possible) |
| Stack | **Flutter (Dart)** |
| Persistance | **100 % local, sans compte** (drift/SQLite + préférences) |
| Gamification | **Niveaux + XP + badges + streaks** |
| Profil | Homme / femme dès l'onboarding |
| Contenu | Catalogue d'exercices maison, versionné en JSON dans les assets |

## 3. La méthode d'entraînement (synthèse)

La méthode n'est **pas un programme linéaire de séances** :

- **4 groupes musculaires** : Bras & Pectoraux, Jambes, Abdominaux, Dos.
- **4 phases par groupe** : Apprentissage · Reprise, Consolidation,
  Athlétisation, Maîtrise (= Athlétisation avec du lest). Chaque phase liste
  4 à 9 exercices réalisables à la maison (poids du corps, kettlebell, sac à
  dos, chaise), et contient des **niveaux** (chaque relèvement d'objectifs
  de +2 répétitions = un niveau).
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
- La **constance** est le cœur du produit : 365 jours, streaks, badges.
- Le contenu est **unisexe** : le choix homme/femme du profil sert à la
  personnalisation (formulations, avatar futur), pas au contenu.

## 4. Transposition en jeu (proposition)

### 4.1 Quatre pistes de progression ("skill tracks")
Chaque groupe musculaire est une piste visuelle de 4 niveaux (phases). La phase
N+1 est **verrouillée** tant que les critères de progression ne sont pas
atteints ; l'app détecte automatiquement le déclencheur (*rule of thumb* sur les
répétitions enregistrées) et propose un "combat de boss" : une séance test qui,
réussie, débloque la phase avec animation de récompense.

### 4.2 La séance quotidienne ("quête du jour")
L'app génère le circuit du jour selon la méthode du programme : 1 exercice par
groupe tiré de la phase courante + focus du jour (rotation hebdomadaire),
minuteur 20 min, compteur de tours et de répétitions, repos chronométré 10–45 s.
L'utilisateur peut échanger un exercice proposé contre un autre de la même phase.

### 4.3 Économie d'XP
- XP par répétition validée + bonus de fin de séance + bonus de streak.
- Niveau de joueur global (distinct des phases) avec seuils croissants.
- Badges : première séance, 7/30/100 jours de streak, phase débloquée,
  record de tours battu, groupe au niveau Pro, etc.
- **Streak compatible avec les jours de repos** : le programme prescrit 2 jours de
  repos/semaine → la série n'est pas cassée par un jour de repos planifié.

### 4.4 Statistiques
Historique des séances, répétitions totales par groupe, graphique de
progression (le signal +10–20 % du programme devient une jauge visible), records.

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
content/        program.json — catalogue exercices/phases extrait du programme
```

### 5.3 Modèle de données
- `Profile` (pseudo, sexe, jours d'entraînement, matériel disponible)
- `MuscleGroup` → `Phase` → `Exercise` (statique, depuis `content/program.json`)
- `ProgressState` : phase courante **par groupe musculaire** (4 curseurs)
- `WorkoutSession` (date, durée, exercices, tours, répétitions par exercice)
- `PlayerState` (XP total, niveau joueur, badges, streak courant/max)
- Moteur : `phaseUpEligibility(records)`, `xpFor(session)`, `streak(records,
  restDays)` — fonctions pures testées unitairement.

## 6. Décisions produit finales

1. **Modèle AMRAP à objectifs fixes** *(révision v2.1)* : chaque mouvement
   porte un **objectif de répétitions fixe par tour** ; le **score de la
   séance = le nombre de tours**. Pendant l'effort, un seul bouton
   **« Fait ✓ »** valide l'objectif ; un bouton discret « ajuster » ouvre le
   compteur à dérouler / ± seulement en cas d'écart. Les exercices jamais
   faits passent par une **calibration** *(révision v3.1)* : pendant la
   première pratique, l'utilisateur fait ce qu'il tient proprement sur
   chaque tour et saisit ses répétitions ; l'objectif retenu est la
   **médiane de ces séries** — le rythme réellement tenable en circuit
   (jamais un « max reps » qui n'a pas de sens au milieu d'un AMRAP).
2. **Évaluation du niveau de départ** *(révision v2.1)* : **quiz de
   placement** à l'onboarding (la checklist du programme, une question par
   groupe musculaire → phase 1/2/3) + **première séance de calibration**
   pour les objectifs de répétitions.
3. **Progression & boss fight** *(révision v2.1)* : objectifs tenus sur
   toutes les séries d'un groupe = séance réussie. 2 réussites consécutives →
   si les objectifs sont sous le seuil de maîtrise (15 reps / 60 s), ils
   sont **relevés de +2** (micro-progression du programme) ; s'ils sont au
   seuil, le **boss fight** est annoncé : séance à objectifs **+2** à tenir
   sur tous les tours → phase débloquée. Boss perdu = boss représenté.
4. **Matériel** : les exercices proposés sont **filtrés selon le matériel
   déclaré** dans le profil (kettlebell, barre de traction, chaise, sac à
   dos, barres parallèles, gilet lesté).
5. **Illustrations** : **pictogrammes animés** (dessinés en vectoriel dans
   l'app — silhouette de profil à deux bras/jambes, accessoires dessinés :
   barre, barres parallèles, chaise, kettlebell).
6. **Nom & concept** *(révision v3)* : l'app s'appelle **365** — deviens fit
   en 365 jours d'entraînement de 20 minutes. Le **numéro du jour
   (Jour N / 365)** est le héros de l'accueil ; une **timeline projetée**
   des arcs (Apprentissage · Reprise → Consolidation → Athlétisation →
   Maîtrise) donne la dimension philosophique du voyage.
7. **Direction artistique** *(révision v3.1)* : **sport / gaming moderne** —
   fond bleu nuit, **gradient signature turquoise → bleu électrique**,
   halos lumineux, typo athlétique **Rajdhani** pour titres et chiffres ;
   logo « 365 · JOURS » en dégradé turquoise/bleu décliné en icônes
   Android/iOS. L'app doit donner envie de s'entraîner.
8. **Plateformes** : Android + iOS (v2), builds produits par la CI.
