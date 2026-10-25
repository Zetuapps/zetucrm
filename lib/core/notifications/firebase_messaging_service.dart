import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notification_service.dart';
import 'notifications_provider.dart';
import '../network/api_client.dart';

/// Top-level background message handler required by FirebaseMessaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('[FCM Background] Received message: ${message.messageId} | ${message.notification?.title}');
}

class FirebaseMessagingService {
  static bool _isFirebaseReady = false;
  static String? _currentToken;

  /// Check if Firebase has been initialized successfully
  static bool get isReady => _isFirebaseReady;

  /// Get currently cached token
  static String? get currentToken => _currentToken;

  /// Initialize Firebase and Firebase Messaging
  static Future<void> init(WidgetRef? ref) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isFirebaseReady = true;
      debugPrint('[FirebaseMessaging] Firebase core initialized successfully');
    } catch (e) {
      _isFirebaseReady = false;
      debugPrint('[FirebaseMessaging] Firebase.initializeApp() skipped or failed: $e');
      debugPrint('[FirebaseMessaging] Please ensure google-services.json (Android) or GoogleService-Info.plist (iOS) is present.');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      // Request notification permissions (required for iOS & Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FirebaseMessaging] Permission authorization status: ${settings.authorizationStatus}');

      // Enable foreground notification presentation on iOS
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FirebaseMessaging] Foreground message arrived: ${message.notification?.title}');

        final title = message.notification?.title ??
            message.data['title'] ??
            'ZetuCRM Notification';
        final body = message.notification?.body ??
            message.data['body'] ??
            '';

        // 1. Show heads-up banner via LocalNotificationService
        LocalNotificationService.showNotification(
          id: message.hashCode,
          title: title,
          body: body,
          data: message.data,
        );

        // 2. Add to in-app reactive notifications list
        if (ref != null) {
          final incoming = AppNotification(
            id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            type: message.data['type']?.toString() ?? 'push',
            title: title,
            body: body,
            data: message.data,
            readAt: null,
            createdAt: DateTime.now(),
          );
          ref.read(notificationsProvider.notifier).addIncomingNotification(incoming);
        }
      });

      // Handle notification tapped when app opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FirebaseMessaging] App opened from background via notification: ${message.data}');
        _handleNotificationAction(message.data);
      });

      // Handle notification tapped when app launched from terminated state
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FirebaseMessaging] App launched from terminated state via notification: ${initialMessage.data}');
        _handleNotificationAction(initialMessage.data);
      }
    } catch (e) {
      debugPrint('[FirebaseMessaging] Setup error: $e');
    }
  }

  /// Sync device FCM token with backend API (/user/fcm-token)
  static Future<void> syncToken(ApiClient apiClient) async {
    if (!_isFirebaseReady) {
      debugPrint('[FirebaseMessaging] Cannot sync token: Firebase is not initialized yet.');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        await _sendTokenToBackend(apiClient, token);
      }

      // Listen for token updates (e.g., token rotated by Google)
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('[FirebaseMessaging] FCM token rotated: $newToken');
        _currentToken = newToken;
        await _sendTokenToBackend(apiClient, newToken);
      });
    } catch (e) {
      debugPrint('[FirebaseMessaging] Error getting FCM token: $e');
    }
  }

  static Future<void> _sendTokenToBackend(ApiClient apiClient, String token) async {
    try {
      final response = await apiClient.dio.post('/user/fcm-token', data: {
        'fcm_token': token,
      });
      if (response.statusCode == 200) {
        debugPrint('[FirebaseMessaging] FCM token registered on backend successfully: ${token.substring(0, 15)}...');
      } else {
        debugPrint('[FirebaseMessaging] Backend returned status ${response.statusCode} for fcm-token update');
      }
    } catch (e) {
      debugPrint('[FirebaseMessaging] Failed sending FCM token to backend: $e');
    }
  }

  static void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    debugPrint('[FirebaseMessaging] Routing notification type: $type');
    // Navigation or action handler can be expanded here
  }
}
