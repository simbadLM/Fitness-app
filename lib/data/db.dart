import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

@DataClassName('SessionRow')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get rounds => integer()();
  IntColumn get xp => integer()();
  TextColumn get bossGroupId => text().nullable()();
  BoolColumn get bossWon => boolean().withDefault(const Constant(false))();
}

@DataClassName('SetLogRow')
class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  TextColumn get exerciseId => text()();
  TextColumn get groupId => text()();
  IntColumn get phase => integer()();
  IntColumn get round => integer()();
  IntColumn get reps => integer()();
  BoolColumn get weighted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDuration => boolean().withDefault(const Constant(false))();
}

class GroupProgressRows extends Table {
  TextColumn get groupId => text()();
  IntColumn get phase => integer().withDefault(const Constant(1))();
  IntColumn get improvementStreak => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {groupId};
}

class PlayerRows extends Table {
  IntColumn get id => integer()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get bossWins => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastTrainingDay => dateTime().nullable()();
  TextColumn get badges => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Sessions, SetLogs, GroupProgressRows, PlayerRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(playerRows).insert(
            const PlayerRowsCompanion(id: Value(0)),
            mode: InsertMode.insertOrIgnore,
          );
        },
      );

  static QueryExecutor _openConnection() => LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        return NativeDatabase.createInBackground(
            File(p.join(dir.path, 'fitness_game.db')));
      });
}
