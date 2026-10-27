import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../auth/auth_provider.dart';

class CallerMatch {
  final String id;
  final String name;
  final String? company;
  final String? phone;
  final String? email;
  final String? leadStatus;
  final bool isCustomer;
  final int dealsCount;
  final Map<String, dynamic>? recentBooking;

  CallerMatch({
    required this.id,
    required this.name,
    this.company,
    this.phone,
    this.email,
    this.leadStatus,
    this.isCustomer = false,
    this.dealsCount = 0,
    this.recentBooking,
  });

  factory CallerMatch.fromJson(Map<String, dynamic> json) {
    return CallerMatch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Contact',
      company: json['company']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      leadStatus: json['lead_status']?.toString(),
      isCustomer: json['is_customer'] == true,
      dealsCount: (json['deals_count'] as num?)?.toInt() ?? 0,
      recentBooking: json['recent_booking'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['recent_booking'])
          : null,
    );
  }
}

class CallerIdService {
  final ApiClient _apiClient;

  CallerIdService(this._apiClient);

  /// Lookup incoming or dialed phone number against authorized CRM records
  Future<CallerMatch?> lookup(String phone) async {
    try {
      final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length < 4) return null;

      final res = await _apiClient.dio.get('/caller-id/lookup', queryParameters: {
        'phone': clean,
      });

      if (res.statusCode == 200 && res.data != null && res.data['found'] == true) {
        return CallerMatch.fromJson(Map<String, dynamic>.from(res.data['contact']));
      }
    } catch (_) {
      // Offline or network error
    }
    return null;
  }
}

final callerIdServiceProvider = Provider<CallerIdService>((ref) {
  return CallerIdService(ref.read(apiClientProvider));
});
