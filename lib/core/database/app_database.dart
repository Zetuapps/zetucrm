import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ── Contacts Table ─────────────────────────────────────────────
@DataClassName('ContactEntry')
class ContactsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_create'))(); // synced, pending_create, pending_update, pending_delete
  TextColumn get firstName => text()();
  TextColumn get middleName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get alternatePhone => text().nullable()();
  TextColumn get tin => text().nullable()();
  TextColumn get vrn => text().nullable()();
  TextColumn get company => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get infoSource => text().nullable()();
  TextColumn get leadStatus => text().nullable()();
  IntColumn get leadScore => integer().withDefault(const Constant(0))();
  BoolColumn get isCustomer => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get country => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get lifecycleStageId => text().nullable()();
  TextColumn get customFieldsJson => text().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
}

// ── Activities Table ───────────────────────────────────────────
@DataClassName('ActivityEntry')
class ActivitiesTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_create'))();
  IntColumn get contactLocalId => integer().nullable()();
  TextColumn get type => text()(); // call, whatsapp, sms, email, meeting, face_to_face, note
  TextColumn get subject => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get direction => text().withDefault(const Constant('outbound'))(); // inbound, outbound
  IntColumn get duration => integer().withDefault(const Constant(0))();
  TextColumn get outcome => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
  DateTimeColumn get localUpdatedAt => dateTime()();
}

// ── Tasks Table ────────────────────────────────────────────────
@DataClassName('TaskEntry')
class TasksTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_create'))();
  IntColumn get contactLocalId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // low, medium, high, urgent
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, in_progress, completed, cancelled
  DateTimeColumn get localUpdatedAt => dateTime()();
}

// ── Deals Table ────────────────────────────────────────────────
@DataClassName('DealEntry')
class DealsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_create'))();
  IntColumn get contactLocalId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get stageName => text().withDefault(const Constant('Qualification'))();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get status => text().withDefault(const Constant('open'))(); // open, won, lost
  TextColumn get stageId => text().nullable()();
  TextColumn get pipelineId => text().nullable()();
  RealColumn get probability => real().nullable()();
  TextColumn get lostReason => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get expectedCloseDate => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();
}

// ── Sync Queue Table ───────────────────────────────────────────
@DataClassName('SyncQueueEntry')
class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // contact, activity, task, deal
  IntColumn get entityLocalId => integer()();
  TextColumn get operation => text()(); // create, update, delete
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [
  ContactsTable,
  ActivitiesTable,
  TasksTable,
  DealsTable,
  SyncQueueTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.addColumn(dealsTable, dealsTable.stageId);
            await m.addColumn(dealsTable, dealsTable.pipelineId);
            await m.addColumn(dealsTable, dealsTable.probability);
            await m.addColumn(dealsTable, dealsTable.lostReason);
            await m.addColumn(dealsTable, dealsTable.notes);
          }
          if (from < 3) {
            await m.addColumn(contactsTable, contactsTable.country);
            await m.addColumn(contactsTable, contactsTable.state);
            await m.addColumn(contactsTable, contactsTable.city);
            await m.addColumn(contactsTable, contactsTable.address);
            await m.addColumn(contactsTable, contactsTable.postalCode);
            await m.addColumn(contactsTable, contactsTable.website);
            await m.addColumn(contactsTable, contactsTable.lifecycleStageId);
            await m.addColumn(contactsTable, contactsTable.customFieldsJson);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'zetucrm.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
