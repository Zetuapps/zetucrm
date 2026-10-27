import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../notifications/firebase_messaging_service.dart';
import '../services/passkey_service.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final bool hasPasskey;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.hasPasskey = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return UserProfile(
      id: rawId?.toString() ?? '0',
      firstName: json['first_name'] ?? json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      role: json['role'] ?? 'Sales Rep',
      hasPasskey: json['has_passkey'] == true || json['passkey'] != null,
    );
  }
}

class CompanyItem {
  final String id;
  final String name;
  final String currency;
  final double exchangeRateUsdTzs;

  CompanyItem({
    required this.id,
    required this.name,
    this.currency = 'TZS',
    this.exchangeRateUsdTzs = 2600.0,
  });

  factory CompanyItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawRate = json['exchange_rate_usd_tzs'];
    return CompanyItem(
      id: rawId?.toString() ?? '0',
      name: json['name'] ?? '',
      currency: json['currency']?.toString().toUpperCase() ?? 'TZS',
      exchangeRateUsdTzs: rawRate is num
          ? rawRate.toDouble()
          : (double.tryParse(rawRate?.toString() ?? '') ?? 2600.0),
    );
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isInitializing;
  final UserProfile? user;
  final List<CompanyItem> companies;
  final CompanyItem? activeCompany;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isInitializing = true,
    this.user,
    this.companies = const [],
    this.activeCompany,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isInitializing,
    UserProfile? user,
    List<CompanyItem>? companies,
    CompanyItem? activeCompany,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      user: user ?? this.user,
      companies: companies ?? this.companies,
      activeCompany: activeCompany ?? this.activeCompany,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    Future.microtask(() => checkLoginStatus());
    return AuthState();
  }

  ApiClient get apiClient => ref.read(apiClientProvider);

  Future<void> checkLoginStatus() async {
    final token = await _storage.read(key: 'sanctum_token');
    if (token != null && token.isNotEmpty) {
      try {
        final res = await apiClient.dio.get('/auth/me');
        if (res.statusCode == 200 && res.data != null) {
          final userData = UserProfile.fromJson(res.data['user'] ?? res.data);
          final companiesList = (res.data['companies'] as List? ?? [])
              .map((c) => CompanyItem.fromJson(c))
              .toList();

          CompanyItem? active;
          final savedCompanyId = await _storage.read(key: 'active_company_id');
          if (savedCompanyId != null) {
            active = companiesList.firstWhere(
              (c) => c.id.toString() == savedCompanyId,
              orElse: () => companiesList.isNotEmpty
                  ? companiesList.first
                  : CompanyItem(id: '1', name: 'Default Company'),
            );
          } else if (companiesList.isNotEmpty) {
            active = companiesList.first;
            await _storage.write(
              key: 'active_company_id',
              value: active.id.toString(),
            );
          }

          state = state.copyWith(
            isAuthenticated: true,
            isInitializing: false,
            user: userData,
            companies: companiesList,
            activeCompany: active,
          );

          // Automatically sync FCM push notification device token
          FirebaseMessagingService.syncToken(apiClient);

          // If this user has a passkey configured, keep their stored token & profile info updated
          final currentToken = await _storage.read(key: 'sanctum_token');
          if (currentToken != null) {
            await PasskeyService.savePasskeySession(
              userId: userData.id,
              token: currentToken,
              email: userData.email,
              userName: userData.fullName,
            );
          }
          return;
        }
      } catch (_) {}
    }
    state = state.copyWith(isAuthenticated: false, isInitializing: false);
  }

  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200) {
        final token = res.data['token'] ?? res.data['access_token'];
        await _storage.write(key: 'sanctum_token', value: token);
        PasskeyService.resetSessionPrompt();
        await checkLoginStatus();
        state = state.copyWith(isLoading: false);
        return true;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data['message'] ??
            'Login failed. Please check your credentials.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred.',
      );
    }
    return false;
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;

      final res = await apiClient.dio.post('/auth/google', data: {
        'id_token': idToken,
        'email': account.email,
        'google_id': account.id,
        'display_name': account.displayName,
        'photo_url': account.photoUrl,
      });

      if (res.statusCode == 200 && res.data != null) {
        final token = res.data['token'] ?? res.data['access_token'];
        if (token != null) {
          await _storage.write(key: 'sanctum_token', value: token.toString());
          PasskeyService.resetSessionPrompt();
          await checkLoginStatus();
          state = state.copyWith(isLoading: false);
          return true;
        }
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google authentication failed to establish a session.',
      );
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          'Google authentication failed (${e.response?.statusCode ?? "Network error"}).';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google sign in failed. Please try again.',
      );
      return false;
    }
  }

  /// Log in with device biometric passkey (Face ID, Touch ID, Fingerprint, or Device Screen Lock)
  Future<bool> loginWithBiometricPasskey({String? userId, String? email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final targetUserId = userId ?? await PasskeyService.getLastPasskeyUserId() ?? 'default';
      final targetEmail = email ?? await PasskeyService.getLastPasskeyEmail();

      // 1. Prompt hardware biometric / device lock authentication
      final authenticated = await PasskeyService.authenticateWithDevice(
        reason: 'Authenticate with your device passkey to sign in to ZetuCRM',
      );
      if (!authenticated) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      // 2. Retrieve the device passkey secret
      final secret = await PasskeyService.getDevicePasskeySecret(targetUserId);

      // If we have a secret and email, authenticate against backend database
      if (secret != null && targetEmail != null && targetEmail.isNotEmpty) {
        try {
          final res = await apiClient.dio.post('/auth/passkey', data: {
            'email': targetEmail,
            'passkey': secret,
          });

          if (res.statusCode == 200 && res.data != null) {
            final token = res.data['token'] ?? res.data['access_token'];
            if (token != null) {
              await _storage.write(key: 'sanctum_token', value: token.toString());
              PasskeyService.resetSessionPrompt();
              await checkLoginStatus();
              state = state.copyWith(isLoading: false);
              return true;
            }
          }
        } on DioException catch (dioErr) {
          if (dioErr.response?.statusCode == 422 ||
              dioErr.response?.statusCode == 401 ||
              dioErr.response?.statusCode == 403) {
            final msg = dioErr.response?.data?['message'] ??
                'Passkey validation failed. Please log in with password.';
            state = state.copyWith(isLoading: false, errorMessage: msg);
            return false;
          }
        }
      }

      // 3. Fallback to cached token for offline support
      final cachedToken = await PasskeyService.getPasskeyToken(targetUserId);
      if (cachedToken != null && cachedToken.isNotEmpty) {
        await _storage.write(key: 'sanctum_token', value: cachedToken);
        PasskeyService.resetSessionPrompt();
        await checkLoginStatus();
        if (state.isAuthenticated) {
          state = state.copyWith(isLoading: false);
          return true;
        }
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in with passkey. Please sign in with your email and password.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Biometric passkey error: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> loginWithPasskey(String userId, String passkey, {String? email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final targetEmail = email ?? await PasskeyService.getLastPasskeyEmail();

      // 1. Authenticate with backend API against users database
      if (targetEmail != null && targetEmail.isNotEmpty) {
        try {
          final res = await apiClient.dio.post('/auth/passkey', data: {
            'email': targetEmail,
            'passkey': passkey.trim(),
          });

          if (res.statusCode == 200 && res.data != null) {
            final token = res.data['token'] ?? res.data['access_token'];
            if (token != null) {
              await _storage.write(key: 'sanctum_token', value: token.toString());
              PasskeyService.resetSessionPrompt();
              await checkLoginStatus();

              // Update local passkey cache with validated token
              if (state.user != null) {
                await PasskeyService.setPasskey(
                  state.user!.id,
                  passkey.trim(),
                  email: state.user!.email,
                  userName: state.user!.fullName,
                  token: token.toString(),
                );
              }

              state = state.copyWith(isLoading: false);
              return true;
            }
          }
        } on DioException catch (dioErr) {
          // If backend returns explicit rejection (422, 401, 403), stop and show backend error
          if (dioErr.response?.statusCode == 422 ||
              dioErr.response?.statusCode == 401 ||
              dioErr.response?.statusCode == 403) {
            final msg = dioErr.response?.data?['message'] ??
                'Invalid passkey. Please check and try again.';
            state = state.copyWith(isLoading: false, errorMessage: msg);
            return false;
          }
          // Network errors: fall through to local fallback
        }
      }

      // 2. Offline / local fallback
      final isValid = await PasskeyService.verifyPasskey(userId, passkey);
      if (!isValid) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Incorrect passkey. Please try again.',
        );
        return false;
      }

      final token = await PasskeyService.getPasskeyToken(userId);
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No active session token found. Please log in with password first.',
        );
        return false;
      }

      await _storage.write(key: 'sanctum_token', value: token);
      PasskeyService.resetSessionPrompt();
      await checkLoginStatus();

      if (!state.isAuthenticated) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Session expired. Please log in with your email and password.',
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Passkey login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> selectCompany(CompanyItem company) async {
    await _storage.write(
      key: 'active_company_id',
      value: company.id.toString(),
    );
    state = state.copyWith(activeCompany: company);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'sanctum_token');
    await _storage.delete(key: 'active_company_id');
    PasskeyService.resetSessionPrompt();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    state = AuthState(isInitializing: false);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
