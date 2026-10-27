import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../network/api_client.dart';

/// Secure biometric & device passkey service for ZetuCRM.
///
/// Uses the device's native biometric system (Face ID, Touch ID, Fingerprint,
/// or Device Screen Lock / Passcode) to authenticate users without typing passwords or PINs.
class PasskeyService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Session flag to ensure we only prompt once per login session if the user chooses to skip.
  static bool _promptedThisSession = false;

  /// Optional mock hook for unit/widget tests running in headless environments
  @visibleForTesting
  static bool? mockAuthenticateResult;

  static bool get hasPromptedThisSession => _promptedThisSession;

  static void markPromptedThisSession() {
    _promptedThisSession = true;
  }

  /// Reset session prompt flag on new login or logout
  static void resetSessionPrompt() {
    _promptedThisSession = false;
  }

  static const String _hasAnyPasskeyKey = 'has_any_passkey';
  static const String _lastUserIdKey = 'last_passkey_user_id';
  static const String _lastEmailKey = 'last_passkey_email';
  static const String _lastNameKey = 'last_passkey_user_name';

  static String _passkeyKey(String userId) =>
      'user_passkey_${userId.isEmpty ? "default" : userId}';
  static String _hasPasskeyKey(String userId) =>
      'has_passkey_${userId.isEmpty ? "default" : userId}';
  static String _passkeyTokenKey(String userId) =>
      'passkey_token_${userId.isEmpty ? "default" : userId}';

  /// Generates a cryptographically strong 64-character hex device passkey token
  static String generatePasskeySecret() {
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Check whether the device hardware supports biometrics or device PIN/passcode
  static Future<bool> isDeviceAuthSupported() async {
    if (mockAuthenticateResult != null) return true;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get the list of available biometric sensors on this device
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    if (mockAuthenticateResult != null) return [BiometricType.face];
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// User-friendly label for device authentication (e.g. "Face ID", "Touch ID", "Fingerprint")
  static Future<String> getBiometricLabel() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris Scanner';
    }
    return 'Device Biometric / Passcode';
  }

  /// Triggers the device's native Face ID, Touch ID, or screen lock verification prompt
  static Future<bool> authenticateWithDevice({
    String reason = 'Authenticate to access your ZetuCRM workspace',
  }) async {
    if (mockAuthenticateResult != null) {
      return mockAuthenticateResult!;
    }
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('[PasskeyService] Device authentication failed: $e');
      return false;
    }
  }

  /// Check whether any passkey is configured on this device
  static Future<bool> hasAnyPasskey() async {
    final flag = await _storage.read(key: _hasAnyPasskeyKey);
    if (flag == 'true') return true;
    final lastUserId = await _storage.read(key: _lastUserIdKey);
    if (lastUserId != null && lastUserId.isNotEmpty) {
      return hasPasskey(lastUserId);
    }
    return false;
  }

  /// Check whether a specific user has an active passkey on this device
  static Future<bool> hasPasskey(String userId) async {
    final pass = await _storage.read(key: _passkeyKey(userId));
    return pass != null && pass.trim().isNotEmpty;
  }

  /// Get details of the last user who configured a passkey
  static Future<String?> getLastPasskeyUserId() =>
      _storage.read(key: _lastUserIdKey);

  static Future<String?> getLastPasskeyEmail() =>
      _storage.read(key: _lastEmailKey);

  static Future<String?> getLastPasskeyUserName() =>
      _storage.read(key: _lastNameKey);

  /// Get the stored device passkey secret
  static Future<String?> getDevicePasskeySecret(String userId) =>
      _storage.read(key: _passkeyKey(userId));

  /// Get the sanctum token stored for passkey quick login
  static Future<String?> getPasskeyToken(String userId) =>
      _storage.read(key: _passkeyTokenKey(userId));

  /// Enables device biometric passkey for user by scanning biometric and syncing secret with backend
  static Future<bool> enableDevicePasskey(
    String userId, {
    required ApiClient apiClient,
    String? email,
    String? userName,
    String? token,
  }) async {
    // 1. Authenticate using device biometrics
    final authenticated = await authenticateWithDevice(
      reason: 'Verify your identity to enable biometric passkey login',
    );
    if (!authenticated) {
      return false;
    }

    // 2. Generate or load device secret
    var secret = await _storage.read(key: _passkeyKey(userId));
    if (secret == null || secret.isEmpty) {
      secret = generatePasskeySecret();
    }

    // 3. Register secret hash in backend database
    try {
      await apiClient.dio.post('/user/passkey', data: {
        'passkey': secret,
      });
    } catch (e) {
      debugPrint('[PasskeyService] Failed to sync passkey to backend: $e');
      // If offline/error, proceed to save locally
    }

    // 4. Save to secure storage on device
    await _storage.write(key: _passkeyKey(userId), value: secret);
    await _storage.write(key: _hasPasskeyKey(userId), value: 'true');
    await _storage.write(key: _hasAnyPasskeyKey, value: 'true');
    await _storage.write(key: _lastUserIdKey, value: userId);

    if (email != null && email.isNotEmpty) {
      await _storage.write(key: _lastEmailKey, value: email);
    }
    if (userName != null && userName.isNotEmpty) {
      await _storage.write(key: _lastNameKey, value: userName);
    }

    final tokenToSave = token ?? await _storage.read(key: 'sanctum_token');
    if (tokenToSave != null && tokenToSave.isNotEmpty) {
      await _storage.write(key: _passkeyTokenKey(userId), value: tokenToSave);
    }

    return true;
  }

  /// Sets / updates a passkey secret directly (used in tests or manual flows)
  static Future<bool> setPasskey(
    String userId,
    String passkey, {
    String? email,
    String? userName,
    String? token,
    ApiClient? apiClient,
  }) async {
    if (apiClient != null) {
      try {
        await apiClient.dio.post('/user/passkey', data: {
          'passkey': passkey.trim(),
        });
      } catch (_) {}
    }

    await _storage.write(key: _passkeyKey(userId), value: passkey.trim());
    await _storage.write(key: _hasPasskeyKey(userId), value: 'true');
    await _storage.write(key: _hasAnyPasskeyKey, value: 'true');
    await _storage.write(key: _lastUserIdKey, value: userId);

    if (email != null && email.isNotEmpty) {
      await _storage.write(key: _lastEmailKey, value: email);
    }
    if (userName != null && userName.isNotEmpty) {
      await _storage.write(key: _lastNameKey, value: userName);
    }

    final tokenToSave = token ?? await _storage.read(key: 'sanctum_token');
    if (tokenToSave != null && tokenToSave.isNotEmpty) {
      await _storage.write(key: _passkeyTokenKey(userId), value: tokenToSave);
    }
    return true;
  }

  /// Updates the stored auth token for an existing passkey user
  static Future<void> savePasskeySession({
    required String userId,
    required String token,
    String? email,
    String? userName,
  }) async {
    final hasExisting = await hasPasskey(userId);
    if (hasExisting) {
      await _storage.write(key: _passkeyTokenKey(userId), value: token);
      await _storage.write(key: _lastUserIdKey, value: userId);
      if (email != null && email.isNotEmpty) {
        await _storage.write(key: _lastEmailKey, value: email);
      }
      if (userName != null && userName.isNotEmpty) {
        await _storage.write(key: _lastNameKey, value: userName);
      }
      await _storage.write(key: _hasAnyPasskeyKey, value: 'true');
    }
  }

  /// Verify entered passkey against stored passkey (compatibility check)
  static Future<bool> verifyPasskey(
      String userId, String enteredPasskey) async {
    final stored = await _storage.read(key: _passkeyKey(userId));
    if (stored == null) return false;
    return stored.trim() == enteredPasskey.trim();
  }

  /// Remove the user's passkey, clearing from backend database if apiClient is provided
  static Future<void> removePasskey(String userId, {ApiClient? apiClient}) async {
    if (apiClient != null) {
      try {
        await apiClient.dio.delete('/user/passkey');
      } catch (_) {}
    }

    await _storage.delete(key: _passkeyKey(userId));
    await _storage.delete(key: _hasPasskeyKey(userId));
    await _storage.delete(key: _passkeyTokenKey(userId));

    final lastUserId = await _storage.read(key: _lastUserIdKey);
    if (lastUserId == userId) {
      await _storage.delete(key: _lastUserIdKey);
      await _storage.delete(key: _lastEmailKey);
      await _storage.delete(key: _lastNameKey);
      await _storage.delete(key: _hasAnyPasskeyKey);
    }
  }
}
