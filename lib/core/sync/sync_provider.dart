import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../auth/auth_provider.dart';

class SyncState {
  final bool isOffline;
  final int pendingCount;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  SyncState({
    this.isOffline = false,
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  SyncState copyWith({
    bool? isOffline,
    int? pendingCount,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      isOffline: isOffline ?? this.isOffline,
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _queueSubscription;

  @override
  SyncState build() {
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
      _queueSubscription?.cancel();
    });

    _initConnectivity();
    _watchPendingCount();
    return SyncState();
  }

  AppDatabase get db => ref.read(databaseProvider);
  ApiClient get apiClient => ref.read(apiClientProvider);

  void _initConnectivity() {
    Connectivity().checkConnectivity().then((results) {
      final isDisconnected = results.contains(ConnectivityResult.none);
      state = state.copyWith(isOffline: isDisconnected);
      if (!isDisconnected) {
        triggerSync();
        pullAllInitialData();
      }
    });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final isDisconnected = results.contains(ConnectivityResult.none);
      state = state.copyWith(isOffline: isDisconnected);
      if (!isDisconnected) {
        triggerSync();
        pullAllInitialData();
      }
    });
  }

  void _watchPendingCount() {
    _queueSubscription = db.select(db.syncQueueTable).watch().listen((queue) {
      state = state.copyWith(pendingCount: queue.length);
    });
  }

  Future<void> triggerSync() async {
    if (state.isOffline || state.isSyncing) return;
    state = state.copyWith(isSyncing: true);

    try {
      final queue = await db.select(db.syncQueueTable).get();
      if (queue.isNotEmpty) {
        final payload = queue
            .map((e) => {
                  'id': e.id,
                  'entity_type': e.entityType,
                  'entity_local_id': e.entityLocalId,
                  'operation': e.operation,
                  'data': e.payloadJson,
                })
            .toList();

        final res =
            await apiClient.dio.post('/sync/batch', data: {'mutations': payload});
        if (res.statusCode == 200) {
          await db.delete(db.syncQueueTable).go();
        }
      }
      state = state.copyWith(isSyncing: false, lastSyncTime: DateTime.now());
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }

  /// Helper to get contact display name following Contact.php's exact getName() logic:
  /// 1. first_name + middle_name + last_name if present
  /// 2. trim(company) . ' (company)' if company present
  /// 3. 'Unnamed Contact'
  String getContactDisplayName(Map<String, dynamic> c) {
    if (c['display_name'] != null && c['display_name'].toString().trim().isNotEmpty) {
      return c['display_name'].toString().trim();
    }

    final nameParts = [
      c['first_name']?.toString(),
      c['middle_name']?.toString(),
      c['last_name']?.toString(),
    ].where((p) => p != null && p.trim().isNotEmpty).join(' ').trim();

    if (nameParts.isNotEmpty) {
      return nameParts;
    }

    final companyStr = c['company']?.toString().trim();
    if (companyStr != null && companyStr.isNotEmpty) {
      return '$companyStr (company)';
    }

    return 'Unnamed Contact';
  }

  /// Pull all initial records from API and store in SQLite so all 4 tabs are populated
  Future<void> pullAllInitialData() async {
    if (state.isOffline) return;

    try {
      // 1. Pull Contacts
      final contactsRes = await apiClient.dio.get('/contacts');
      if (contactsRes.statusCode == 200 && contactsRes.data != null) {
        final List contactsList = contactsRes.data['data'] ?? (contactsRes.data is List ? contactsRes.data : []);
        for (var c in contactsList) {
          final sId = c['id']?.toString() ?? '';
          if (sId.isEmpty) continue;
          final existing = await (db.select(db.contactsTable)..where((t) => t.serverId.equals(sId))).getSingleOrNull();

          final displayName = getContactDisplayName(c);
          final isCustBool = c['is_customer'] == true || c['is_customer'] == 1 || c['is_customer'] == '1';
          final isActBool = c['is_active'] == true || c['is_active'] == 1 || c['is_active'] == '1' || c['is_active'] == null;

          final customFieldsStr = c['custom_fields'] != null ? jsonEncode(c['custom_fields']) : null;

          if (existing == null) {
            await db.into(db.contactsTable).insert(
                  ContactsTableCompanion.insert(
                    serverId: Value(sId),
                    syncStatus: const Value('synced'),
                    firstName: displayName,
                    middleName: Value(c['middle_name']?.toString()),
                    lastName: Value(c['last_name']?.toString()),
                    email: Value(c['email']?.toString()),
                    phone: Value(c['phone']?.toString()),
                    alternatePhone: Value(c['alternate_phone']?.toString()),
                    tin: Value(c['tin']?.toString()),
                    vrn: Value(c['vrn']?.toString()),
                    company: Value(c['company']?.toString()),
                    title: Value(c['title']?.toString()),
                    infoSource: Value(c['info_source']?.toString()),
                    leadStatus: Value(c['lead_status']?.toString()),
                    leadScore: Value((c['lead_score'] as num?)?.toInt() ?? 0),
                    isCustomer: Value(isCustBool),
                    notes: Value(c['notes']?.toString()),
                    isActive: Value(isActBool),
                    country: Value(c['country']?.toString()),
                    state: Value(c['state']?.toString()),
                    city: Value(c['city']?.toString()),
                    address: Value(c['address']?.toString()),
                    postalCode: Value(c['postal_code']?.toString()),
                    website: Value(c['website']?.toString()),
                    lifecycleStageId: Value(c['lifecycle_stage_id']?.toString()),
                    customFieldsJson: Value(customFieldsStr),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
          } else {
            await (db.update(db.contactsTable)..where((t) => t.serverId.equals(sId))).write(
              ContactsTableCompanion(
                firstName: Value(displayName),
                middleName: Value(c['middle_name']?.toString()),
                lastName: Value(c['last_name']?.toString()),
                email: Value(c['email']?.toString()),
                phone: Value(c['phone']?.toString()),
                alternatePhone: Value(c['alternate_phone']?.toString()),
                tin: Value(c['tin']?.toString()),
                vrn: Value(c['vrn']?.toString()),
                company: Value(c['company']?.toString()),
                title: Value(c['title']?.toString()),
                infoSource: Value(c['info_source']?.toString()),
                leadStatus: Value(c['lead_status']?.toString()),
                leadScore: Value((c['lead_score'] as num?)?.toInt() ?? 0),
                isCustomer: Value(isCustBool),
                notes: Value(c['notes']?.toString()),
                country: Value(c['country']?.toString()),
                state: Value(c['state']?.toString()),
                city: Value(c['city']?.toString()),
                address: Value(c['address']?.toString()),
                postalCode: Value(c['postal_code']?.toString()),
                website: Value(c['website']?.toString()),
                lifecycleStageId: Value(c['lifecycle_stage_id']?.toString()),
                customFieldsJson: Value(customFieldsStr),
              ),
            );
          }
        }
      }

      // 2. Pull Deals
      final dealsRes = await apiClient.dio.get('/deals');
      if (dealsRes.statusCode == 200 && dealsRes.data != null) {
        final List dealsList = dealsRes.data['data'] ?? (dealsRes.data is List ? dealsRes.data : []);
        for (var d in dealsList) {
          final sId = d['id']?.toString() ?? '';
          if (sId.isEmpty) continue;
          final existing = await (db.select(db.dealsTable)..where((t) => t.serverId.equals(sId))).getSingleOrNull();
          
          final stageName = d['stage'] is Map ? d['stage']['name'] : (d['stage']?.toString() ?? 'Qualification');
          final rawAmount = d['amount'];
          final parsedAmount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse(rawAmount?.toString() ?? '') ?? 0.0);

          if (existing == null) {
            await db.into(db.dealsTable).insert(
                  DealsTableCompanion.insert(
                    serverId: Value(sId),
                    syncStatus: const Value('synced'),
                    title: d['title'] ?? d['name'] ?? 'Deal',
                    stageName: Value(stageName),
                    amount: Value(parsedAmount),
                    status: Value(d['status']?.toString() ?? 'open'),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
          } else {
            await (db.update(db.dealsTable)..where((t) => t.serverId.equals(sId))).write(
              DealsTableCompanion(
                title: Value(d['title'] ?? d['name'] ?? 'Deal'),
                stageName: Value(stageName),
                amount: Value(parsedAmount),
                status: Value(d['status']?.toString() ?? 'open'),
              ),
            );
          }
        }
      }

      // 3. Pull Activities
      final activitiesRes = await apiClient.dio.get('/activities');
      if (activitiesRes.statusCode == 200 && activitiesRes.data != null) {
        final List activitiesList = activitiesRes.data['data'] ?? (activitiesRes.data is List ? activitiesRes.data : []);
        for (var a in activitiesList) {
          final sId = a['id']?.toString() ?? '';
          if (sId.isEmpty) continue;
          final existing = await (db.select(db.activitiesTable)..where((t) => t.serverId.equals(sId))).getSingleOrNull();
          final isCompBool = a['is_completed'] == true || a['is_completed'] == 1 || a['is_completed'] == '1';

          if (existing == null) {
            await db.into(db.activitiesTable).insert(
                  ActivitiesTableCompanion.insert(
                    serverId: Value(sId),
                    syncStatus: const Value('synced'),
                    type: a['type']?.toString() ?? 'call',
                    subject: Value(a['subject']?.toString() ?? a['title']?.toString() ?? 'Activity'),
                    description: Value(a['description']?.toString() ?? a['notes']?.toString()),
                    isCompleted: Value(isCompBool),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
          } else {
            await (db.update(db.activitiesTable)..where((t) => t.serverId.equals(sId))).write(
              ActivitiesTableCompanion(
                type: Value(a['type']?.toString() ?? 'call'),
                subject: Value(a['subject']?.toString() ?? a['title']?.toString() ?? 'Activity'),
                description: Value(a['description']?.toString() ?? a['notes']?.toString()),
                isCompleted: Value(isCompBool),
              ),
            );
          }
        }
      }

      // 4. Pull Tasks
      final tasksRes = await apiClient.dio.get('/tasks');
      if (tasksRes.statusCode == 200 && tasksRes.data != null) {
        final List tasksList = tasksRes.data['data'] ?? (tasksRes.data is List ? tasksRes.data : []);
        for (var t in tasksList) {
          final sId = t['id']?.toString() ?? '';
          if (sId.isEmpty) continue;
          final existing = await (db.select(db.tasksTable)..where((t) => t.serverId.equals(sId))).getSingleOrNull();

          if (existing == null) {
            await db.into(db.tasksTable).insert(
                  TasksTableCompanion.insert(
                    serverId: Value(sId),
                    syncStatus: const Value('synced'),
                    title: t['title']?.toString() ?? t['subject']?.toString() ?? 'Task',
                    description: Value(t['description']?.toString()),
                    priority: Value(t['priority']?.toString() ?? 'medium'),
                    status: Value(t['status']?.toString() ?? 'pending'),
                    dueDate: Value(t['due_date'] != null ? DateTime.tryParse(t['due_date'].toString()) : null),
                    localUpdatedAt: DateTime.now(),
                  ),
                );
          } else {
            await (db.update(db.tasksTable)..where((t) => t.serverId.equals(sId))).write(
              TasksTableCompanion(
                title: Value(t['title']?.toString() ?? t['subject']?.toString() ?? 'Task'),
                description: Value(t['description']?.toString()),
                priority: Value(t['priority']?.toString() ?? 'medium'),
                status: Value(t['status']?.toString() ?? 'pending'),
              ),
            );
          }
        }
      }
    } catch (e, stack) {
      print('SYNC ERROR IN PULL INITIAL DATA: $e\n$stack');
    }
  }
}

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
