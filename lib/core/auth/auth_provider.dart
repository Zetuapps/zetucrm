import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
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
      });

      if (res.statusCode == 200) {
        final token = res.data['token'];
        await _storage.write(key: 'sanctum_token', value: token);
        await checkLoginStatus();
        state = state.copyWith(isLoading: false);
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google sign in failed. Please try again.',
      );
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<void> selectCompany(CompanyItem company) async {
    await _storage.write(
      key: 'active_company_id',
      value: company.id.toString(),
    );
    state = state.copyWith(activeCompany: company);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    state = AuthState(isInitializing: false);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
