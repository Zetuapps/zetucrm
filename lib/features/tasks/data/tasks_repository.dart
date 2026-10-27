import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/network/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_provider.dart';
import '../../../core/notifications/local_notification_service.dart';

class TasksRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;

  TasksRepository(this._apiClient, this._db);

  /// Create and persist a reminder or task directly to the backend database
  Future<TaskEntry> createReminder({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? contactServerId,
    int? contactLocalId,
    String type = 'call',
    int remindBeforeMinutes = 60,
  }) async {
    String? serverId;

    try {
      final res = await _apiClient.dio.post('/tasks', data: {
        'title': title,
        'description': description,
        'priority': priority ?? 'medium',
        'status': 'pending',
        'due_date': dueDate?.toIso8601String(),
        'type': type,
        'contact_id': contactServerId,
        'remind_before_minutes': remindBeforeMinutes,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        serverId = data['id']?.toString();
      }
    } catch (_) {
      // Offline fallback
    }

    final companion = TasksTableCompanion.insert(
      serverId: drift.Value(serverId),
      syncStatus: drift.Value(serverId != null ? 'synced' : 'pending_create'),
      contactLocalId: drift.Value(contactLocalId),
      title: title,
      description: drift.Value(description),
      priority: drift.Value(priority ?? 'medium'),
      status: const drift.Value('pending'),
      dueDate: drift.Value(dueDate),
      localUpdatedAt: DateTime.now(),
    );

    final localId = await _db.into(_db.tasksTable).insert(companion);

    // Schedule local OS notification reminder if due date is provided
    if (dueDate != null) {
      final triggerTime = dueDate.subtract(Duration(minutes: remindBeforeMinutes));
      if (triggerTime.isAfter(DateTime.now())) {
        await LocalNotificationService.scheduleTaskReminder(
          id: localId,
          title: '$type reminder: $title',
          body: description?.isNotEmpty == true ? description! : 'Scheduled for ${dueDate.toString().substring(0, 16)}',
          scheduledDate: triggerTime,
        );
      }
    }

    return (await (_db.select(_db.tasksTable)..where((t) => t.localId.equals(localId))).getSingle());
  }

  /// Update status (e.g. mark completed)
  Future<void> updateStatus(TaskEntry task, String newStatus) async {
    // 1. Update SQLite immediately
    await (_db.update(_db.tasksTable)..where((t) => t.localId.equals(task.localId))).write(
      TasksTableCompanion(
        status: drift.Value(newStatus),
        localUpdatedAt: drift.Value(DateTime.now()),
      ),
    );

    // 2. Submit to backend if server ID exists
    if (task.serverId != null) {
      try {
        await _apiClient.dio.put('/tasks/${task.serverId}', data: {
          'status': newStatus,
          if (newStatus == 'completed') 'completed_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
  }

  /// Reschedule a reminder
  Future<void> reschedule(TaskEntry task, DateTime newDueDate) async {
    await (_db.update(_db.tasksTable)..where((t) => t.localId.equals(task.localId))).write(
      TasksTableCompanion(
        dueDate: drift.Value(newDueDate),
        localUpdatedAt: drift.Value(DateTime.now()),
      ),
    );

    if (task.serverId != null) {
      try {
        await _apiClient.dio.put('/tasks/${task.serverId}', data: {
          'due_date': newDueDate.toIso8601String(),
        });
      } catch (_) {}
    }

    // Reschedule local notification
    await LocalNotificationService.scheduleTaskReminder(
      id: task.localId,
      title: 'Task Due: ${task.title}',
      body: task.description ?? 'Rescheduled reminder',
      scheduledDate: newDueDate,
    );
  }

  /// Cancel or delete a task
  Future<void> deleteTask(TaskEntry task) async {
    await (_db.delete(_db.tasksTable)..where((t) => t.localId.equals(task.localId))).go();

    if (task.serverId != null) {
      try {
        await _apiClient.dio.delete('/tasks/${task.serverId}');
      } catch (_) {}
    }
  }
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(
    ref.read(apiClientProvider),
    ref.read(databaseProvider),
  );
});
