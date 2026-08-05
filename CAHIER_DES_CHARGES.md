# Cahier des charges — Application sportive gamifiée (Android)

> **Version 0.1 — brouillon de cadrage.** Les sections marquées `⏳ EN ATTENTE`
> dépendent du contenu du guide PDF, non encore fourni.

## 1. Vision

Transformer un guide d'entraînement (PDF) en application Android interactive et
gamifiée : l'utilisateur progresse dans un programme sportif dont les niveaux se
débloquent séquentiellement, comme dans un jeu (modèle Duolingo / Candy Crush).

## 2. Décisions actées

| Sujet | Décision | Justification |
|---|---|---|
| Plateforme | Android (portage iOS possible plus tard) | Demande initiale |
| Stack | **Flutter (Dart)** | Cross-platform, excellent pour les animations de gamification |
| Persistance | **100 % local, sans compte** | Confidentialité, simplicité, pas de backend |
| Gamification | **Niveaux + XP + badges + streaks** | Standard éprouvé (Duolingo) |
| Profil | Paramétrage **homme / femme** dès l'onboarding | Demande initiale |
| Langue | Français (i18n prévue dans l'architecture) | À confirmer |

## 3. Fonctionnalités

### 3.1 Onboarding & profil
- Premier lancement : création du profil — prénom/pseudo, sexe (homme/femme),
  éventuellement âge, poids, taille, niveau de départ (à confirmer selon le guide).
- Le profil est modifiable ensuite dans les paramètres.
- ⏳ EN ATTENTE : impact précis du sexe sur le programme (variantes d'exercices ?
  charges ? programmes distincts ?) — dépend du guide PDF.

### 3.2 Carte de progression (écran principal)
- Parcours visuel des niveaux (chemin type "carte de jeu") ; états : `verrouillé`,
  `débloqué`, `en cours`, `terminé` (avec score 1–3 étoiles éventuel).
- Un niveau N+1 se débloque quand le niveau N est validé.
- ⏳ EN ATTENTE : découpage réel en niveaux/semaines/séances selon le guide.

### 3.3 Exécution d'une séance
- Enchaînement guidé des exercices : nom, illustration/animation, consignes,
  séries × répétitions ou durée.
- Minuteur intégré (effort / repos), navigation exercice suivant/précédent,
  pause, abandon (progression non validée).
- Fin de séance : écran de récompense (XP gagnés, badge éventuel, streak).

### 3.4 Moteur de gamification
- **XP** : attribués à chaque séance terminée (barème à définir : base + bonus
  régularité/perfection).
- **Niveaux de joueur** (distincts des niveaux du programme) : seuils d'XP
  croissants.
- **Badges/succès** : première séance, 7 jours de streak, programme à 50 %,
  programme terminé, etc. (liste à finaliser).
- **Streak** : jours consécutifs avec activité ; gel de streak à discuter.

### 3.5 Statistiques & historique
- Historique des séances (date, durée, contenu).
- Courbes de progression, total XP, records.

### 3.6 Paramètres
- Profil, notifications/rappels d'entraînement (à confirmer), sons/vibrations,
  réinitialisation de la progression (avec double confirmation).

## 4. Architecture technique (niveau ingénieur)

### 4.1 Stack
- **Flutter** stable (Dart 3), Android `minSdk 26` (à confirmer).
- **Gestion d'état** : Riverpod (ou Bloc — à trancher, Riverpod recommandé).
- **Persistance** :
  - `drift` (SQLite typé) pour l'historique des séances et la progression ;
  - `shared_preferences` / `flutter_secure_storage` pour le profil et les réglages.
- **Navigation** : `go_router`.
- **Tests** : unitaires (moteur de gamification, déblocage de niveaux),
  widget tests, golden tests sur les écrans clés.
- **CI** : GitHub Actions — `flutter analyze` + `flutter test` + build APK.

### 4.2 Découpage en couches
```
presentation/   écrans, widgets, animations (dépend de domain)
domain/         entités, use cases, moteur de gamification (pur Dart, 100 % testable)
data/           repositories, drift, préférences (implémente les interfaces de domain)
content/        programme d'entraînement versionné (assets JSON générés depuis le PDF)
```

### 4.3 Modèle de données (première ébauche)
- `Profile` (sexe, prénom, préférences)
- `Program` → `Level` → `Session` → `Exercise` (contenu statique, versionné, en assets)
- `SessionRecord` (séance réalisée : date, durée, XP)
- `PlayerState` (XP total, badges débloqués, streak courant/max, dernier jour actif)
- Règle de déblocage = fonction pure `unlockState(program, records)` → testée unitairement.

### 4.4 Contenu
Le guide PDF sera converti en un fichier de contenu structuré (JSON dans les
assets), séparé du code : le programme peut évoluer sans toucher à la logique.

## 5. Questions ouvertes (à valider par le propriétaire)

1. **Le guide PDF** : à fournir (voir README) — il conditionne les sections 3.1, 3.2, 4.4.
2. Différenciation homme/femme : programmes distincts ou variantes ?
3. Rappels/notifications d'entraînement : oui/non, quelle logique ?
4. Score par niveau (1–3 étoiles) : souhaité ou simple validé/non validé ?
5. Direction artistique : thème sombre/clair, univers graphique (sport brut,
   cartoon, minimaliste…), nom de l'application.
6. Matériel requis par le guide (poids du corps ? haltères ?) — impacte les écrans.
7. Âge/poids/taille dans le profil : utiles (calories ?) ou superflus ?
