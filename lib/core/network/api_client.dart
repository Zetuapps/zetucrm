import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://4dd2-197-186-65-14.ngrok-free.app/api/v1';
  // 'https://crm.zetuapps.com/api/v1';
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({Dio? dioInstance, FlutterSecureStorage? secureStorage})
    : dio = dioInstance ?? Dio(),
      storage = secureStorage ?? const FlutterSecureStorage() {
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'sanctum_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final companyId = await storage.read(key: 'active_company_id');
          if (companyId != null && companyId.isNotEmpty) {
            options.headers['X-Company-Id'] = companyId;
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            await storage.delete(key: 'sanctum_token');
          }
          return handler.next(error);
        },
      ),
    );
  }
}
