import 'dart:convert';

/// Matériel à domicile. Un exercice liste des alternatives : il est disponible
/// si l'utilisateur possède AU MOINS UN des éléments (liste vide = aucun requis).
enum Equipment {
  chair('Chaise solide'),
  kettlebell('Kettlebell'),
  backpack('Sac à dos lesté'),
  pullupBar('Barre de traction'),
  dipBars('Barres parallèles'),
  weightVest('Gilet lesté');

  const Equipment(this.labelFr);
  final String labelFr;
}

enum PictoType {
  pushup,
  dip,
  curl,
  press,
  squat,
  jumpsquat,
  calfraise,
  lunge,
  stepup,
  bridge,
  swing,
  hinge,
  plank,
  climber,
  crunch,
  deadbug,
  legraise,
  vup,
  twist,
  situp,
  pullup,
  hangraise,
  row,
  handstand,
  march,
  superman,
}

enum ExerciseType { reps, duration }

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.picto,
    this.note,
    this.equipment = const [],
    this.type = ExerciseType.reps,
  });

  final String id;
  final String name;
  final String? note;
  final List<Equipment> equipment;
  final PictoType picto;
  final ExerciseType type;

  bool availableWith(Set<Equipment> owned) =>
      equipment.isEmpty || equipment.any(owned.contains);

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        note: json['note'] as String?,
        equipment: [
          for (final e in (json['equipment'] as List? ?? const []))
            Equipment.values.byName(e as String),
        ],
        picto: PictoType.values.byName(json['picto'] as String),
        type: json['type'] == 'duration' ? ExerciseType.duration : ExerciseType.reps,
      );
}

class PhaseContent {
  const PhaseContent({
    required this.phase,
    required this.label,
    this.exercises = const [],
    this.rule,
  });

  final int phase;
  final String label;
  final List<Exercise> exercises;
  final String? rule;

  factory PhaseContent.fromJson(Map<String, dynamic> json) => PhaseContent(
        phase: json['phase'] as int,
        label: json['label'] as String,
        exercises: [
          for (final e in (json['exercises'] as List? ?? const []))
            Exercise.fromJson(e as Map<String, dynamic>),
        ],
        rule: json['rule'] as String?,
      );
}

class MuscleGroup {
  const MuscleGroup({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.phases,
  });

  final String id;
  final String nameFr;
  final String nameEn;
  final List<PhaseContent> phases;

  static const int maxPhase = 4;

  /// La phase 4 (Pro) réutilise les exercices de la phase 3 avec du lest.
  List<Exercise> exercisesForPhase(int phase) {
    final effective = phase >= 4 ? 3 : phase;
    return phases.firstWhere((p) => p.phase == effective).exercises;
  }

  String phaseLabel(int phase) =>
      phases.firstWhere((p) => p.phase == phase).label;

  factory MuscleGroup.fromJson(Map<String, dynamic> json) => MuscleGroup(
        id: json['id'] as String,
        nameFr: json['nameFr'] as String,
        nameEn: json['nameEn'] as String,
        phases: [
          for (final p in (json['phases'] as List))
            PhaseContent.fromJson(p as Map<String, dynamic>),
        ],
      );
}

/// Paramètres de la méthode d'entraînement (circuits AMRAP de 20 minutes).
class Method {
  const Method({
    this.sessionDuration = const Duration(minutes: 20),
    this.defaultRest = const Duration(seconds: 30),
  });

  final Duration sessionDuration;
  final Duration defaultRest;
}

class Program {
  const Program({required this.groups, this.method = const Method()});

  final List<MuscleGroup> groups;
  final Method method;

  MuscleGroup group(String id) => groups.firstWhere((g) => g.id == id);

  Exercise? findExercise(String exerciseId) {
    for (final g in groups) {
      for (final p in g.phases) {
        for (final e in p.exercises) {
          if (e.id == exerciseId) return e;
        }
      }
    }
    return null;
  }

  factory Program.fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return Program(
      groups: [
        for (final g in (json['muscleGroups'] as List))
          MuscleGroup.fromJson(g as Map<String, dynamic>),
      ],
    );
  }
}
