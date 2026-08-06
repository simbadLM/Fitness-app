// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bossGroupIdMeta = const VerificationMeta(
    'bossGroupId',
  );
  @override
  late final GeneratedColumn<String> bossGroupId = GeneratedColumn<String>(
    'boss_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bossWonMeta = const VerificationMeta(
    'bossWon',
  );
  @override
  late final GeneratedColumn<bool> bossWon = GeneratedColumn<bool>(
    'boss_won',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("boss_won" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    durationSeconds,
    rounds,
    xp,
    bossGroupId,
    bossWon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    } else if (isInserting) {
      context.missing(_roundsMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    } else if (isInserting) {
      context.missing(_xpMeta);
    }
    if (data.containsKey('boss_group_id')) {
      context.handle(
        _bossGroupIdMeta,
        bossGroupId.isAcceptableOrUnknown(
          data['boss_group_id']!,
          _bossGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('boss_won')) {
      context.handle(
        _bossWonMeta,
        bossWon.isAcceptableOrUnknown(data['boss_won']!, _bossWonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      bossGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_group_id'],
      ),
      bossWon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}boss_won'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final int id;
  final DateTime date;
  final int durationSeconds;
  final int rounds;
  final int xp;
  final String? bossGroupId;
  final bool bossWon;
  const SessionRow({
    required this.id,
    required this.date,
    required this.durationSeconds,
    required this.rounds,
    required this.xp,
    this.bossGroupId,
    required this.bossWon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['rounds'] = Variable<int>(rounds);
    map['xp'] = Variable<int>(xp);
    if (!nullToAbsent || bossGroupId != null) {
      map['boss_group_id'] = Variable<String>(bossGroupId);
    }
    map['boss_won'] = Variable<bool>(bossWon);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      date: Value(date),
      durationSeconds: Value(durationSeconds),
      rounds: Value(rounds),
      xp: Value(xp),
      bossGroupId: bossGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(bossGroupId),
      bossWon: Value(bossWon),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      rounds: serializer.fromJson<int>(json['rounds']),
      xp: serializer.fromJson<int>(json['xp']),
      bossGroupId: serializer.fromJson<String?>(json['bossGroupId']),
      bossWon: serializer.fromJson<bool>(json['bossWon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'rounds': serializer.toJson<int>(rounds),
      'xp': serializer.toJson<int>(xp),
      'bossGroupId': serializer.toJson<String?>(bossGroupId),
      'bossWon': serializer.toJson<bool>(bossWon),
    };
  }

  SessionRow copyWith({
    int? id,
    DateTime? date,
    int? durationSeconds,
    int? rounds,
    int? xp,
    Value<String?> bossGroupId = const Value.absent(),
    bool? bossWon,
  }) => SessionRow(
    id: id ?? this.id,
    date: date ?? this.date,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    rounds: rounds ?? this.rounds,
    xp: xp ?? this.xp,
    bossGroupId: bossGroupId.present ? bossGroupId.value : this.bossGroupId,
    bossWon: bossWon ?? this.bossWon,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      xp: data.xp.present ? data.xp.value : this.xp,
      bossGroupId: data.bossGroupId.present
          ? data.bossGroupId.value
          : this.bossGroupId,
      bossWon: data.bossWon.present ? data.bossWon.value : this.bossWon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rounds: $rounds, ')
          ..write('xp: $xp, ')
          ..write('bossGroupId: $bossGroupId, ')
          ..write('bossWon: $bossWon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, durationSeconds, rounds, xp, bossGroupId, bossWon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.durationSeconds == this.durationSeconds &&
          other.rounds == this.rounds &&
          other.xp == this.xp &&
          other.bossGroupId == this.bossGroupId &&
          other.bossWon == this.bossWon);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> durationSeconds;
  final Value<int> rounds;
  final Value<int> xp;
  final Value<String?> bossGroupId;
  final Value<bool> bossWon;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rounds = const Value.absent(),
    this.xp = const Value.absent(),
    this.bossGroupId = const Value.absent(),
    this.bossWon = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int durationSeconds,
    required int rounds,
    required int xp,
    this.bossGroupId = const Value.absent(),
    this.bossWon = const Value.absent(),
  }) : date = Value(date),
       durationSeconds = Value(durationSeconds),
       rounds = Value(rounds),
       xp = Value(xp);
  static Insertable<SessionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? durationSeconds,
    Expression<int>? rounds,
    Expression<int>? xp,
    Expression<String>? bossGroupId,
    Expression<bool>? bossWon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rounds != null) 'rounds': rounds,
      if (xp != null) 'xp': xp,
      if (bossGroupId != null) 'boss_group_id': bossGroupId,
      if (bossWon != null) 'boss_won': bossWon,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? durationSeconds,
    Value<int>? rounds,
    Value<int>? xp,
    Value<String?>? bossGroupId,
    Value<bool>? bossWon,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rounds: rounds ?? this.rounds,
      xp: xp ?? this.xp,
      bossGroupId: bossGroupId ?? this.bossGroupId,
      bossWon: bossWon ?? this.bossWon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (bossGroupId.present) {
      map['boss_group_id'] = Variable<String>(bossGroupId.value);
    }
    if (bossWon.present) {
      map['boss_won'] = Variable<bool>(bossWon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rounds: $rounds, ')
          ..write('xp: $xp, ')
          ..write('bossGroupId: $bossGroupId, ')
          ..write('bossWon: $bossWon')
          ..write(')'))
        .toString();
  }
}

class $SetLogsTable extends SetLogs with TableInfo<$SetLogsTable, SetLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<int> phase = GeneratedColumn<int>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightedMeta = const VerificationMeta(
    'weighted',
  );
  @override
  late final GeneratedColumn<bool> weighted = GeneratedColumn<bool>(
    'weighted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weighted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDurationMeta = const VerificationMeta(
    'isDuration',
  );
  @override
  late final GeneratedColumn<bool> isDuration = GeneratedColumn<bool>(
    'is_duration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_duration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    groupId,
    phase,
    round,
    reps,
    weighted,
    isDuration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    } else if (isInserting) {
      context.missing(_roundMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weighted')) {
      context.handle(
        _weightedMeta,
        weighted.isAcceptableOrUnknown(data['weighted']!, _weightedMeta),
      );
    }
    if (data.containsKey('is_duration')) {
      context.handle(
        _isDurationMeta,
        isDuration.isAcceptableOrUnknown(data['is_duration']!, _isDurationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase'],
      )!,
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      weighted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weighted'],
      )!,
      isDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_duration'],
      )!,
    );
  }

  @override
  $SetLogsTable createAlias(String alias) {
    return $SetLogsTable(attachedDatabase, alias);
  }
}

class SetLogRow extends DataClass implements Insertable<SetLogRow> {
  final int id;
  final int sessionId;
  final String exerciseId;
  final String groupId;
  final int phase;
  final int round;
  final int reps;
  final bool weighted;
  final bool isDuration;
  const SetLogRow({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.groupId,
    required this.phase,
    required this.round,
    required this.reps,
    required this.weighted,
    required this.isDuration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['group_id'] = Variable<String>(groupId);
    map['phase'] = Variable<int>(phase);
    map['round'] = Variable<int>(round);
    map['reps'] = Variable<int>(reps);
    map['weighted'] = Variable<bool>(weighted);
    map['is_duration'] = Variable<bool>(isDuration);
    return map;
  }

  SetLogsCompanion toCompanion(bool nullToAbsent) {
    return SetLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      groupId: Value(groupId),
      phase: Value(phase),
      round: Value(round),
      reps: Value(reps),
      weighted: Value(weighted),
      isDuration: Value(isDuration),
    );
  }

  factory SetLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetLogRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      phase: serializer.fromJson<int>(json['phase']),
      round: serializer.fromJson<int>(json['round']),
      reps: serializer.fromJson<int>(json['reps']),
      weighted: serializer.fromJson<bool>(json['weighted']),
      isDuration: serializer.fromJson<bool>(json['isDuration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'groupId': serializer.toJson<String>(groupId),
      'phase': serializer.toJson<int>(phase),
      'round': serializer.toJson<int>(round),
      'reps': serializer.toJson<int>(reps),
      'weighted': serializer.toJson<bool>(weighted),
      'isDuration': serializer.toJson<bool>(isDuration),
    };
  }

  SetLogRow copyWith({
    int? id,
    int? sessionId,
    String? exerciseId,
    String? groupId,
    int? phase,
    int? round,
    int? reps,
    bool? weighted,
    bool? isDuration,
  }) => SetLogRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    groupId: groupId ?? this.groupId,
    phase: phase ?? this.phase,
    round: round ?? this.round,
    reps: reps ?? this.reps,
    weighted: weighted ?? this.weighted,
    isDuration: isDuration ?? this.isDuration,
  );
  SetLogRow copyWithCompanion(SetLogsCompanion data) {
    return SetLogRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      phase: data.phase.present ? data.phase.value : this.phase,
      round: data.round.present ? data.round.value : this.round,
      reps: data.reps.present ? data.reps.value : this.reps,
      weighted: data.weighted.present ? data.weighted.value : this.weighted,
      isDuration: data.isDuration.present
          ? data.isDuration.value
          : this.isDuration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetLogRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('groupId: $groupId, ')
          ..write('phase: $phase, ')
          ..write('round: $round, ')
          ..write('reps: $reps, ')
          ..write('weighted: $weighted, ')
          ..write('isDuration: $isDuration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    groupId,
    phase,
    round,
    reps,
    weighted,
    isDuration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetLogRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.groupId == this.groupId &&
          other.phase == this.phase &&
          other.round == this.round &&
          other.reps == this.reps &&
          other.weighted == this.weighted &&
          other.isDuration == this.isDuration);
}

class SetLogsCompanion extends UpdateCompanion<SetLogRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> exerciseId;
  final Value<String> groupId;
  final Value<int> phase;
  final Value<int> round;
  final Value<int> reps;
  final Value<bool> weighted;
  final Value<bool> isDuration;
  const SetLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.phase = const Value.absent(),
    this.round = const Value.absent(),
    this.reps = const Value.absent(),
    this.weighted = const Value.absent(),
    this.isDuration = const Value.absent(),
  });
  SetLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String exerciseId,
    required String groupId,
    required int phase,
    required int round,
    required int reps,
    this.weighted = const Value.absent(),
    this.isDuration = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       groupId = Value(groupId),
       phase = Value(phase),
       round = Value(round),
       reps = Value(reps);
  static Insertable<SetLogRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? exerciseId,
    Expression<String>? groupId,
    Expression<int>? phase,
    Expression<int>? round,
    Expression<int>? reps,
    Expression<bool>? weighted,
    Expression<bool>? isDuration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (groupId != null) 'group_id': groupId,
      if (phase != null) 'phase': phase,
      if (round != null) 'round': round,
      if (reps != null) 'reps': reps,
      if (weighted != null) 'weighted': weighted,
      if (isDuration != null) 'is_duration': isDuration,
    });
  }

  SetLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? exerciseId,
    Value<String>? groupId,
    Value<int>? phase,
    Value<int>? round,
    Value<int>? reps,
    Value<bool>? weighted,
    Value<bool>? isDuration,
  }) {
    return SetLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      groupId: groupId ?? this.groupId,
      phase: phase ?? this.phase,
      round: round ?? this.round,
      reps: reps ?? this.reps,
      weighted: weighted ?? this.weighted,
      isDuration: isDuration ?? this.isDuration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (phase.present) {
      map['phase'] = Variable<int>(phase.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weighted.present) {
      map['weighted'] = Variable<bool>(weighted.value);
    }
    if (isDuration.present) {
      map['is_duration'] = Variable<bool>(isDuration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('groupId: $groupId, ')
          ..write('phase: $phase, ')
          ..write('round: $round, ')
          ..write('reps: $reps, ')
          ..write('weighted: $weighted, ')
          ..write('isDuration: $isDuration')
          ..write(')'))
        .toString();
  }
}

class $ExerciseTargetsTable extends ExerciseTargets
    with TableInfo<$ExerciseTargetsTable, ExerciseTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, target];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseTarget(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
    );
  }

  @override
  $ExerciseTargetsTable createAlias(String alias) {
    return $ExerciseTargetsTable(attachedDatabase, alias);
  }
}

class ExerciseTarget extends DataClass implements Insertable<ExerciseTarget> {
  final String exerciseId;
  final int target;
  const ExerciseTarget({required this.exerciseId, required this.target});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['target'] = Variable<int>(target);
    return map;
  }

  ExerciseTargetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseTargetsCompanion(
      exerciseId: Value(exerciseId),
      target: Value(target),
    );
  }

  factory ExerciseTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseTarget(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      target: serializer.fromJson<int>(json['target']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'target': serializer.toJson<int>(target),
    };
  }

  ExerciseTarget copyWith({String? exerciseId, int? target}) => ExerciseTarget(
    exerciseId: exerciseId ?? this.exerciseId,
    target: target ?? this.target,
  );
  ExerciseTarget copyWithCompanion(ExerciseTargetsCompanion data) {
    return ExerciseTarget(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      target: data.target.present ? data.target.value : this.target,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTarget(')
          ..write('exerciseId: $exerciseId, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, target);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseTarget &&
          other.exerciseId == this.exerciseId &&
          other.target == this.target);
}

class ExerciseTargetsCompanion extends UpdateCompanion<ExerciseTarget> {
  final Value<String> exerciseId;
  final Value<int> target;
  final Value<int> rowid;
  const ExerciseTargetsCompanion({
    this.exerciseId = const Value.absent(),
    this.target = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseTargetsCompanion.insert({
    required String exerciseId,
    required int target,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       target = Value(target);
  static Insertable<ExerciseTarget> custom({
    Expression<String>? exerciseId,
    Expression<int>? target,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (target != null) 'target': target,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseTargetsCompanion copyWith({
    Value<String>? exerciseId,
    Value<int>? target,
    Value<int>? rowid,
  }) {
    return ExerciseTargetsCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      target: target ?? this.target,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTargetsCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('target: $target, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupProgressRowsTable extends GroupProgressRows
    with TableInfo<$GroupProgressRowsTable, GroupProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupProgressRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<int> phase = GeneratedColumn<int>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _improvementStreakMeta = const VerificationMeta(
    'improvementStreak',
  );
  @override
  late final GeneratedColumn<int> improvementStreak = GeneratedColumn<int>(
    'improvement_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelInPhaseMeta = const VerificationMeta(
    'levelInPhase',
  );
  @override
  late final GeneratedColumn<int> levelInPhase = GeneratedColumn<int>(
    'level_in_phase',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    phase,
    improvementStreak,
    levelInPhase,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_progress_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('improvement_streak')) {
      context.handle(
        _improvementStreakMeta,
        improvementStreak.isAcceptableOrUnknown(
          data['improvement_streak']!,
          _improvementStreakMeta,
        ),
      );
    }
    if (data.containsKey('level_in_phase')) {
      context.handle(
        _levelInPhaseMeta,
        levelInPhase.isAcceptableOrUnknown(
          data['level_in_phase']!,
          _levelInPhaseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  GroupProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupProgressRow(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase'],
      )!,
      improvementStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}improvement_streak'],
      )!,
      levelInPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_in_phase'],
      )!,
    );
  }

  @override
  $GroupProgressRowsTable createAlias(String alias) {
    return $GroupProgressRowsTable(attachedDatabase, alias);
  }
}

class GroupProgressRow extends DataClass
    implements Insertable<GroupProgressRow> {
  final String groupId;
  final int phase;
  final int improvementStreak;

  /// Niveau au sein de la phase : +1 à chaque relèvement d'objectifs (+2).
  final int levelInPhase;
  const GroupProgressRow({
    required this.groupId,
    required this.phase,
    required this.improvementStreak,
    required this.levelInPhase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['phase'] = Variable<int>(phase);
    map['improvement_streak'] = Variable<int>(improvementStreak);
    map['level_in_phase'] = Variable<int>(levelInPhase);
    return map;
  }

  GroupProgressRowsCompanion toCompanion(bool nullToAbsent) {
    return GroupProgressRowsCompanion(
      groupId: Value(groupId),
      phase: Value(phase),
      improvementStreak: Value(improvementStreak),
      levelInPhase: Value(levelInPhase),
    );
  }

  factory GroupProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupProgressRow(
      groupId: serializer.fromJson<String>(json['groupId']),
      phase: serializer.fromJson<int>(json['phase']),
      improvementStreak: serializer.fromJson<int>(json['improvementStreak']),
      levelInPhase: serializer.fromJson<int>(json['levelInPhase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'phase': serializer.toJson<int>(phase),
      'improvementStreak': serializer.toJson<int>(improvementStreak),
      'levelInPhase': serializer.toJson<int>(levelInPhase),
    };
  }

  GroupProgressRow copyWith({
    String? groupId,
    int? phase,
    int? improvementStreak,
    int? levelInPhase,
  }) => GroupProgressRow(
    groupId: groupId ?? this.groupId,
    phase: phase ?? this.phase,
    improvementStreak: improvementStreak ?? this.improvementStreak,
    levelInPhase: levelInPhase ?? this.levelInPhase,
  );
  GroupProgressRow copyWithCompanion(GroupProgressRowsCompanion data) {
    return GroupProgressRow(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      phase: data.phase.present ? data.phase.value : this.phase,
      improvementStreak: data.improvementStreak.present
          ? data.improvementStreak.value
          : this.improvementStreak,
      levelInPhase: data.levelInPhase.present
          ? data.levelInPhase.value
          : this.levelInPhase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupProgressRow(')
          ..write('groupId: $groupId, ')
          ..write('phase: $phase, ')
          ..write('improvementStreak: $improvementStreak, ')
          ..write('levelInPhase: $levelInPhase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(groupId, phase, improvementStreak, levelInPhase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupProgressRow &&
          other.groupId == this.groupId &&
          other.phase == this.phase &&
          other.improvementStreak == this.improvementStreak &&
          other.levelInPhase == this.levelInPhase);
}

class GroupProgressRowsCompanion extends UpdateCompanion<GroupProgressRow> {
  final Value<String> groupId;
  final Value<int> phase;
  final Value<int> improvementStreak;
  final Value<int> levelInPhase;
  final Value<int> rowid;
  const GroupProgressRowsCompanion({
    this.groupId = const Value.absent(),
    this.phase = const Value.absent(),
    this.improvementStreak = const Value.absent(),
    this.levelInPhase = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupProgressRowsCompanion.insert({
    required String groupId,
    this.phase = const Value.absent(),
    this.improvementStreak = const Value.absent(),
    this.levelInPhase = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId);
  static Insertable<GroupProgressRow> custom({
    Expression<String>? groupId,
    Expression<int>? phase,
    Expression<int>? improvementStreak,
    Expression<int>? levelInPhase,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (phase != null) 'phase': phase,
      if (improvementStreak != null) 'improvement_streak': improvementStreak,
      if (levelInPhase != null) 'level_in_phase': levelInPhase,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupProgressRowsCompanion copyWith({
    Value<String>? groupId,
    Value<int>? phase,
    Value<int>? improvementStreak,
    Value<int>? levelInPhase,
    Value<int>? rowid,
  }) {
    return GroupProgressRowsCompanion(
      groupId: groupId ?? this.groupId,
      phase: phase ?? this.phase,
      improvementStreak: improvementStreak ?? this.improvementStreak,
      levelInPhase: levelInPhase ?? this.levelInPhase,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (phase.present) {
      map['phase'] = Variable<int>(phase.value);
    }
    if (improvementStreak.present) {
      map['improvement_streak'] = Variable<int>(improvementStreak.value);
    }
    if (levelInPhase.present) {
      map['level_in_phase'] = Variable<int>(levelInPhase.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupProgressRowsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('phase: $phase, ')
          ..write('improvementStreak: $improvementStreak, ')
          ..write('levelInPhase: $levelInPhase, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerRowsTable extends PlayerRows
    with TableInfo<$PlayerRowsTable, PlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bossWinsMeta = const VerificationMeta(
    'bossWins',
  );
  @override
  late final GeneratedColumn<int> bossWins = GeneratedColumn<int>(
    'boss_wins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastTrainingDayMeta = const VerificationMeta(
    'lastTrainingDay',
  );
  @override
  late final GeneratedColumn<DateTime> lastTrainingDay =
      GeneratedColumn<DateTime>(
        'last_training_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _badgesMeta = const VerificationMeta('badges');
  @override
  late final GeneratedColumn<String> badges = GeneratedColumn<String>(
    'badges',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    xp,
    streak,
    bestStreak,
    bossWins,
    lastTrainingDay,
    badges,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('boss_wins')) {
      context.handle(
        _bossWinsMeta,
        bossWins.isAcceptableOrUnknown(data['boss_wins']!, _bossWinsMeta),
      );
    }
    if (data.containsKey('last_training_day')) {
      context.handle(
        _lastTrainingDayMeta,
        lastTrainingDay.isAcceptableOrUnknown(
          data['last_training_day']!,
          _lastTrainingDayMeta,
        ),
      );
    }
    if (data.containsKey('badges')) {
      context.handle(
        _badgesMeta,
        badges.isAcceptableOrUnknown(data['badges']!, _badgesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      bossWins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boss_wins'],
      )!,
      lastTrainingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_training_day'],
      ),
      badges: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badges'],
      )!,
    );
  }

  @override
  $PlayerRowsTable createAlias(String alias) {
    return $PlayerRowsTable(attachedDatabase, alias);
  }
}

class PlayerRow extends DataClass implements Insertable<PlayerRow> {
  final int id;
  final int xp;
  final int streak;
  final int bestStreak;
  final int bossWins;
  final DateTime? lastTrainingDay;
  final String badges;
  const PlayerRow({
    required this.id,
    required this.xp,
    required this.streak,
    required this.bestStreak,
    required this.bossWins,
    this.lastTrainingDay,
    required this.badges,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['xp'] = Variable<int>(xp);
    map['streak'] = Variable<int>(streak);
    map['best_streak'] = Variable<int>(bestStreak);
    map['boss_wins'] = Variable<int>(bossWins);
    if (!nullToAbsent || lastTrainingDay != null) {
      map['last_training_day'] = Variable<DateTime>(lastTrainingDay);
    }
    map['badges'] = Variable<String>(badges);
    return map;
  }

  PlayerRowsCompanion toCompanion(bool nullToAbsent) {
    return PlayerRowsCompanion(
      id: Value(id),
      xp: Value(xp),
      streak: Value(streak),
      bestStreak: Value(bestStreak),
      bossWins: Value(bossWins),
      lastTrainingDay: lastTrainingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTrainingDay),
      badges: Value(badges),
    );
  }

  factory PlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerRow(
      id: serializer.fromJson<int>(json['id']),
      xp: serializer.fromJson<int>(json['xp']),
      streak: serializer.fromJson<int>(json['streak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      bossWins: serializer.fromJson<int>(json['bossWins']),
      lastTrainingDay: serializer.fromJson<DateTime?>(json['lastTrainingDay']),
      badges: serializer.fromJson<String>(json['badges']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'xp': serializer.toJson<int>(xp),
      'streak': serializer.toJson<int>(streak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'bossWins': serializer.toJson<int>(bossWins),
      'lastTrainingDay': serializer.toJson<DateTime?>(lastTrainingDay),
      'badges': serializer.toJson<String>(badges),
    };
  }

  PlayerRow copyWith({
    int? id,
    int? xp,
    int? streak,
    int? bestStreak,
    int? bossWins,
    Value<DateTime?> lastTrainingDay = const Value.absent(),
    String? badges,
  }) => PlayerRow(
    id: id ?? this.id,
    xp: xp ?? this.xp,
    streak: streak ?? this.streak,
    bestStreak: bestStreak ?? this.bestStreak,
    bossWins: bossWins ?? this.bossWins,
    lastTrainingDay: lastTrainingDay.present
        ? lastTrainingDay.value
        : this.lastTrainingDay,
    badges: badges ?? this.badges,
  );
  PlayerRow copyWithCompanion(PlayerRowsCompanion data) {
    return PlayerRow(
      id: data.id.present ? data.id.value : this.id,
      xp: data.xp.present ? data.xp.value : this.xp,
      streak: data.streak.present ? data.streak.value : this.streak,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      bossWins: data.bossWins.present ? data.bossWins.value : this.bossWins,
      lastTrainingDay: data.lastTrainingDay.present
          ? data.lastTrainingDay.value
          : this.lastTrainingDay,
      badges: data.badges.present ? data.badges.value : this.badges,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRow(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('streak: $streak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('bossWins: $bossWins, ')
          ..write('lastTrainingDay: $lastTrainingDay, ')
          ..write('badges: $badges')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    xp,
    streak,
    bestStreak,
    bossWins,
    lastTrainingDay,
    badges,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerRow &&
          other.id == this.id &&
          other.xp == this.xp &&
          other.streak == this.streak &&
          other.bestStreak == this.bestStreak &&
          other.bossWins == this.bossWins &&
          other.lastTrainingDay == this.lastTrainingDay &&
          other.badges == this.badges);
}

class PlayerRowsCompanion extends UpdateCompanion<PlayerRow> {
  final Value<int> id;
  final Value<int> xp;
  final Value<int> streak;
  final Value<int> bestStreak;
  final Value<int> bossWins;
  final Value<DateTime?> lastTrainingDay;
  final Value<String> badges;
  const PlayerRowsCompanion({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.streak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.bossWins = const Value.absent(),
    this.lastTrainingDay = const Value.absent(),
    this.badges = const Value.absent(),
  });
  PlayerRowsCompanion.insert({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.streak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.bossWins = const Value.absent(),
    this.lastTrainingDay = const Value.absent(),
    this.badges = const Value.absent(),
  });
  static Insertable<PlayerRow> custom({
    Expression<int>? id,
    Expression<int>? xp,
    Expression<int>? streak,
    Expression<int>? bestStreak,
    Expression<int>? bossWins,
    Expression<DateTime>? lastTrainingDay,
    Expression<String>? badges,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (xp != null) 'xp': xp,
      if (streak != null) 'streak': streak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (bossWins != null) 'boss_wins': bossWins,
      if (lastTrainingDay != null) 'last_training_day': lastTrainingDay,
      if (badges != null) 'badges': badges,
    });
  }

  PlayerRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? xp,
    Value<int>? streak,
    Value<int>? bestStreak,
    Value<int>? bossWins,
    Value<DateTime?>? lastTrainingDay,
    Value<String>? badges,
  }) {
    return PlayerRowsCompanion(
      id: id ?? this.id,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      bossWins: bossWins ?? this.bossWins,
      lastTrainingDay: lastTrainingDay ?? this.lastTrainingDay,
      badges: badges ?? this.badges,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (bossWins.present) {
      map['boss_wins'] = Variable<int>(bossWins.value);
    }
    if (lastTrainingDay.present) {
      map['last_training_day'] = Variable<DateTime>(lastTrainingDay.value);
    }
    if (badges.present) {
      map['badges'] = Variable<String>(badges.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRowsCompanion(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('streak: $streak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('bossWins: $bossWins, ')
          ..write('lastTrainingDay: $lastTrainingDay, ')
          ..write('badges: $badges')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SetLogsTable setLogs = $SetLogsTable(this);
  late final $ExerciseTargetsTable exerciseTargets = $ExerciseTargetsTable(
    this,
  );
  late final $GroupProgressRowsTable groupProgressRows =
      $GroupProgressRowsTable(this);
  late final $PlayerRowsTable playerRows = $PlayerRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    setLogs,
    exerciseTargets,
    groupProgressRows,
    playerRows,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int durationSeconds,
      required int rounds,
      required int xp,
      Value<String?> bossGroupId,
      Value<bool> bossWon,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> durationSeconds,
      Value<int> rounds,
      Value<int> xp,
      Value<String?> bossGroupId,
      Value<bool> bossWon,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SetLogsTable, List<SetLogRow>> _setLogsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.setLogs,
    aliasName: 'sessions__id__set_logs__session_id',
  );

  $$SetLogsTableProcessedTableManager get setLogsRefs {
    final manager = $$SetLogsTableTableManager(
      $_db,
      $_db.setLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bossGroupId => $composableBuilder(
    column: $table.bossGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bossWon => $composableBuilder(
    column: $table.bossWon,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> setLogsRefs(
    Expression<bool> Function($$SetLogsTableFilterComposer f) f,
  ) {
    final $$SetLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetLogsTableFilterComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bossGroupId => $composableBuilder(
    column: $table.bossGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bossWon => $composableBuilder(
    column: $table.bossWon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<String> get bossGroupId => $composableBuilder(
    column: $table.bossGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bossWon =>
      $composableBuilder(column: $table.bossWon, builder: (column) => column);

  Expression<T> setLogsRefs<T extends Object>(
    Expression<T> Function($$SetLogsTableAnnotationComposer a) f,
  ) {
    final $$SetLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool setLogsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<String?> bossGroupId = const Value.absent(),
                Value<bool> bossWon = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                date: date,
                durationSeconds: durationSeconds,
                rounds: rounds,
                xp: xp,
                bossGroupId: bossGroupId,
                bossWon: bossWon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int durationSeconds,
                required int rounds,
                required int xp,
                Value<String?> bossGroupId = const Value.absent(),
                Value<bool> bossWon = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                date: date,
                durationSeconds: durationSeconds,
                rounds: rounds,
                xp: xp,
                bossGroupId: bossGroupId,
                bossWon: bossWon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setLogsRefs) db.setLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setLogsRefs)
                    await $_getPrefetchedData<
                      SessionRow,
                      $SessionsTable,
                      SetLogRow
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._setLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).setLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool setLogsRefs})
    >;
typedef $$SetLogsTableCreateCompanionBuilder =
    SetLogsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String exerciseId,
      required String groupId,
      required int phase,
      required int round,
      required int reps,
      Value<bool> weighted,
      Value<bool> isDuration,
    });
typedef $$SetLogsTableUpdateCompanionBuilder =
    SetLogsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> exerciseId,
      Value<String> groupId,
      Value<int> phase,
      Value<int> round,
      Value<int> reps,
      Value<bool> weighted,
      Value<bool> isDuration,
    });

final class $$SetLogsTableReferences
    extends BaseReferences<_$AppDatabase, $SetLogsTable, SetLogRow> {
  $$SetLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('set_logs__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weighted => $composableBuilder(
    column: $table.weighted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDuration => $composableBuilder(
    column: $table.isDuration,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weighted => $composableBuilder(
    column: $table.weighted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDuration => $composableBuilder(
    column: $table.isDuration,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<bool> get weighted =>
      $composableBuilder(column: $table.weighted, builder: (column) => column);

  GeneratedColumn<bool> get isDuration => $composableBuilder(
    column: $table.isDuration,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetLogsTable,
          SetLogRow,
          $$SetLogsTableFilterComposer,
          $$SetLogsTableOrderingComposer,
          $$SetLogsTableAnnotationComposer,
          $$SetLogsTableCreateCompanionBuilder,
          $$SetLogsTableUpdateCompanionBuilder,
          (SetLogRow, $$SetLogsTableReferences),
          SetLogRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SetLogsTableTableManager(_$AppDatabase db, $SetLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<int> phase = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<bool> weighted = const Value.absent(),
                Value<bool> isDuration = const Value.absent(),
              }) => SetLogsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                groupId: groupId,
                phase: phase,
                round: round,
                reps: reps,
                weighted: weighted,
                isDuration: isDuration,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String exerciseId,
                required String groupId,
                required int phase,
                required int round,
                required int reps,
                Value<bool> weighted = const Value.absent(),
                Value<bool> isDuration = const Value.absent(),
              }) => SetLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                groupId: groupId,
                phase: phase,
                round: round,
                reps: reps,
                weighted: weighted,
                isDuration: isDuration,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SetLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SetLogsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SetLogsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetLogsTable,
      SetLogRow,
      $$SetLogsTableFilterComposer,
      $$SetLogsTableOrderingComposer,
      $$SetLogsTableAnnotationComposer,
      $$SetLogsTableCreateCompanionBuilder,
      $$SetLogsTableUpdateCompanionBuilder,
      (SetLogRow, $$SetLogsTableReferences),
      SetLogRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ExerciseTargetsTableCreateCompanionBuilder =
    ExerciseTargetsCompanion Function({
      required String exerciseId,
      required int target,
      Value<int> rowid,
    });
typedef $$ExerciseTargetsTableUpdateCompanionBuilder =
    ExerciseTargetsCompanion Function({
      Value<String> exerciseId,
      Value<int> target,
      Value<int> rowid,
    });

class $$ExerciseTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseTargetsTable> {
  $$ExerciseTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseTargetsTable> {
  $$ExerciseTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseTargetsTable> {
  $$ExerciseTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);
}

class $$ExerciseTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseTargetsTable,
          ExerciseTarget,
          $$ExerciseTargetsTableFilterComposer,
          $$ExerciseTargetsTableOrderingComposer,
          $$ExerciseTargetsTableAnnotationComposer,
          $$ExerciseTargetsTableCreateCompanionBuilder,
          $$ExerciseTargetsTableUpdateCompanionBuilder,
          (
            ExerciseTarget,
            BaseReferences<
              _$AppDatabase,
              $ExerciseTargetsTable,
              ExerciseTarget
            >,
          ),
          ExerciseTarget,
          PrefetchHooks Function()
        > {
  $$ExerciseTargetsTableTableManager(
    _$AppDatabase db,
    $ExerciseTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTargetsCompanion(
                exerciseId: exerciseId,
                target: target,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required int target,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTargetsCompanion.insert(
                exerciseId: exerciseId,
                target: target,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseTargetsTable,
      ExerciseTarget,
      $$ExerciseTargetsTableFilterComposer,
      $$ExerciseTargetsTableOrderingComposer,
      $$ExerciseTargetsTableAnnotationComposer,
      $$ExerciseTargetsTableCreateCompanionBuilder,
      $$ExerciseTargetsTableUpdateCompanionBuilder,
      (
        ExerciseTarget,
        BaseReferences<_$AppDatabase, $ExerciseTargetsTable, ExerciseTarget>,
      ),
      ExerciseTarget,
      PrefetchHooks Function()
    >;
typedef $$GroupProgressRowsTableCreateCompanionBuilder =
    GroupProgressRowsCompanion Function({
      required String groupId,
      Value<int> phase,
      Value<int> improvementStreak,
      Value<int> levelInPhase,
      Value<int> rowid,
    });
typedef $$GroupProgressRowsTableUpdateCompanionBuilder =
    GroupProgressRowsCompanion Function({
      Value<String> groupId,
      Value<int> phase,
      Value<int> improvementStreak,
      Value<int> levelInPhase,
      Value<int> rowid,
    });

class $$GroupProgressRowsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupProgressRowsTable> {
  $$GroupProgressRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get improvementStreak => $composableBuilder(
    column: $table.improvementStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelInPhase => $composableBuilder(
    column: $table.levelInPhase,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroupProgressRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupProgressRowsTable> {
  $$GroupProgressRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get improvementStreak => $composableBuilder(
    column: $table.improvementStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelInPhase => $composableBuilder(
    column: $table.levelInPhase,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupProgressRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupProgressRowsTable> {
  $$GroupProgressRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get improvementStreak => $composableBuilder(
    column: $table.improvementStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get levelInPhase => $composableBuilder(
    column: $table.levelInPhase,
    builder: (column) => column,
  );
}

class $$GroupProgressRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupProgressRowsTable,
          GroupProgressRow,
          $$GroupProgressRowsTableFilterComposer,
          $$GroupProgressRowsTableOrderingComposer,
          $$GroupProgressRowsTableAnnotationComposer,
          $$GroupProgressRowsTableCreateCompanionBuilder,
          $$GroupProgressRowsTableUpdateCompanionBuilder,
          (
            GroupProgressRow,
            BaseReferences<
              _$AppDatabase,
              $GroupProgressRowsTable,
              GroupProgressRow
            >,
          ),
          GroupProgressRow,
          PrefetchHooks Function()
        > {
  $$GroupProgressRowsTableTableManager(
    _$AppDatabase db,
    $GroupProgressRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupProgressRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupProgressRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupProgressRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<int> phase = const Value.absent(),
                Value<int> improvementStreak = const Value.absent(),
                Value<int> levelInPhase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupProgressRowsCompanion(
                groupId: groupId,
                phase: phase,
                improvementStreak: improvementStreak,
                levelInPhase: levelInPhase,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                Value<int> phase = const Value.absent(),
                Value<int> improvementStreak = const Value.absent(),
                Value<int> levelInPhase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupProgressRowsCompanion.insert(
                groupId: groupId,
                phase: phase,
                improvementStreak: improvementStreak,
                levelInPhase: levelInPhase,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroupProgressRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupProgressRowsTable,
      GroupProgressRow,
      $$GroupProgressRowsTableFilterComposer,
      $$GroupProgressRowsTableOrderingComposer,
      $$GroupProgressRowsTableAnnotationComposer,
      $$GroupProgressRowsTableCreateCompanionBuilder,
      $$GroupProgressRowsTableUpdateCompanionBuilder,
      (
        GroupProgressRow,
        BaseReferences<
          _$AppDatabase,
          $GroupProgressRowsTable,
          GroupProgressRow
        >,
      ),
      GroupProgressRow,
      PrefetchHooks Function()
    >;
typedef $$PlayerRowsTableCreateCompanionBuilder =
    PlayerRowsCompanion Function({
      Value<int> id,
      Value<int> xp,
      Value<int> streak,
      Value<int> bestStreak,
      Value<int> bossWins,
      Value<DateTime?> lastTrainingDay,
      Value<String> badges,
    });
typedef $$PlayerRowsTableUpdateCompanionBuilder =
    PlayerRowsCompanion Function({
      Value<int> id,
      Value<int> xp,
      Value<int> streak,
      Value<int> bestStreak,
      Value<int> bossWins,
      Value<DateTime?> lastTrainingDay,
      Value<String> badges,
    });

class $$PlayerRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerRowsTable> {
  $$PlayerRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bossWins => $composableBuilder(
    column: $table.bossWins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTrainingDay => $composableBuilder(
    column: $table.lastTrainingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badges => $composableBuilder(
    column: $table.badges,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerRowsTable> {
  $$PlayerRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bossWins => $composableBuilder(
    column: $table.bossWins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTrainingDay => $composableBuilder(
    column: $table.lastTrainingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badges => $composableBuilder(
    column: $table.badges,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerRowsTable> {
  $$PlayerRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bossWins =>
      $composableBuilder(column: $table.bossWins, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTrainingDay => $composableBuilder(
    column: $table.lastTrainingDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get badges =>
      $composableBuilder(column: $table.badges, builder: (column) => column);
}

class $$PlayerRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerRowsTable,
          PlayerRow,
          $$PlayerRowsTableFilterComposer,
          $$PlayerRowsTableOrderingComposer,
          $$PlayerRowsTableAnnotationComposer,
          $$PlayerRowsTableCreateCompanionBuilder,
          $$PlayerRowsTableUpdateCompanionBuilder,
          (
            PlayerRow,
            BaseReferences<_$AppDatabase, $PlayerRowsTable, PlayerRow>,
          ),
          PlayerRow,
          PrefetchHooks Function()
        > {
  $$PlayerRowsTableTableManager(_$AppDatabase db, $PlayerRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<int> bossWins = const Value.absent(),
                Value<DateTime?> lastTrainingDay = const Value.absent(),
                Value<String> badges = const Value.absent(),
              }) => PlayerRowsCompanion(
                id: id,
                xp: xp,
                streak: streak,
                bestStreak: bestStreak,
                bossWins: bossWins,
                lastTrainingDay: lastTrainingDay,
                badges: badges,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<int> bossWins = const Value.absent(),
                Value<DateTime?> lastTrainingDay = const Value.absent(),
                Value<String> badges = const Value.absent(),
              }) => PlayerRowsCompanion.insert(
                id: id,
                xp: xp,
                streak: streak,
                bestStreak: bestStreak,
                bossWins: bossWins,
                lastTrainingDay: lastTrainingDay,
                badges: badges,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerRowsTable,
      PlayerRow,
      $$PlayerRowsTableFilterComposer,
      $$PlayerRowsTableOrderingComposer,
      $$PlayerRowsTableAnnotationComposer,
      $$PlayerRowsTableCreateCompanionBuilder,
      $$PlayerRowsTableUpdateCompanionBuilder,
      (PlayerRow, BaseReferences<_$AppDatabase, $PlayerRowsTable, PlayerRow>),
      PlayerRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SetLogsTableTableManager get setLogs =>
      $$SetLogsTableTableManager(_db, _db.setLogs);
  $$ExerciseTargetsTableTableManager get exerciseTargets =>
      $$ExerciseTargetsTableTableManager(_db, _db.exerciseTargets);
  $$GroupProgressRowsTableTableManager get groupProgressRows =>
      $$GroupProgressRowsTableTableManager(_db, _db.groupProgressRows);
  $$PlayerRowsTableTableManager get playerRows =>
      $$PlayerRowsTableTableManager(_db, _db.playerRows);
}
