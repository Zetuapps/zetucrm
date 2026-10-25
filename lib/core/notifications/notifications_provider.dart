import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../auth/auth_provider.dart';

class AppNotification {
  final String id;
  final String? companyId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.companyId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString(),
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : {},
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? companyId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      Future.microtask(() => loadNotifications());
    }
    return NotificationsState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);

  /// Fetch notifications from backend
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.get('/notifications');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? {};
        final unreadCount = data['unread_count'] as int? ?? 0;
        final listData = data['notifications']?['data'] as List? ??
            data['notifications'] as List? ??
            [];

        final items = listData
            .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        state = state.copyWith(
          notifications: items,
          unreadCount: unreadCount,
          isLoading: false,
        );
        return;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notifications: $e',
      );
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String id) async {
    final index = state.notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final original = state.notifications[index];
    if (original.isRead) return;

    // Optimistically update
    final updatedList = List<AppNotification>.from(state.notifications);
    updatedList[index] = original.copyWith(readAt: DateTime.now());
    final newUnread = (state.unreadCount - 1).clamp(0, 9999);

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: newUnread,
    );

    try {
      await _apiClient.dio.post('/notifications/$id/read');
    } catch (_) {
      // Revert if failed
      state = state.copyWith(
        notifications: state.notifications,
        unreadCount: state.unreadCount,
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;

    final updatedList = state.notifications
        .map((n) => n.isRead ? n : n.copyWith(readAt: DateTime.now()))
        .toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
    );

    try {
      await _apiClient.dio.post('/notifications/mark-all-read');
    } catch (_) {
      await loadNotifications();
    }
  }

  /// Delete a single notification
  Future<void> deleteNotification(String id) async {
    final toRemove = state.notifications.firstWhere(
      (n) => n.id == id,
      orElse: () => state.notifications.first,
    );
    final wasUnread = !toRemove.isRead;

    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
      unreadCount: wasUnread
          ? (state.unreadCount - 1).clamp(0, 9999)
          : state.unreadCount,
    );

    try {
      await _apiClient.dio.delete('/notifications/$id');
    } catch (_) {
      await loadNotifications();
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    state = state.copyWith(
      notifications: const [],
      unreadCount: 0,
    );

    try {
      await _apiClient.dio.delete('/notifications/clear-all');
    } catch (_) {
      await loadNotifications();
    }
  }

  /// Add incoming notification from foreground FCM push
  void addIncomingNotification(AppNotification notification) {
    final updated = [notification, ...state.notifications];
    state = state.copyWith(
      notifications: updated,
      unreadCount: state.unreadCount + 1,
    );
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
