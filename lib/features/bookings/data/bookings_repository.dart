import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import 'models/booking_model.dart';

class BookingsResponse {
  final List<BookingModel> bookings;
  final Map<String, int> stats;
  final int total;
  final int currentPage;

  BookingsResponse({
    required this.bookings,
    required this.stats,
    required this.total,
    required this.currentPage,
  });
}

class BookingsRepository {
  final ApiClient _apiClient;

  BookingsRepository(this._apiClient);

  /// Fetch bookings list from backend with filters
  Future<BookingsResponse> getBookings({
    String? status,
    String? search,
    String? from,
    String? to,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (status != null && status != 'all') 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };

    final res = await _apiClient.dio.get('/bookings', queryParameters: queryParams);

    final List dataList = res.data['data'] as List? ?? [];
    final bookings = dataList
        .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
        .toList();

    final rawStats = res.data['stats'] as Map<String, dynamic>? ?? {};
    final stats = <String, int>{
      'total': (rawStats['total'] as num?)?.toInt() ?? 0,
      'upcoming': (rawStats['upcoming'] as num?)?.toInt() ?? 0,
      'completed': (rawStats['completed'] as num?)?.toInt() ?? 0,
      'cancelled': (rawStats['cancelled'] as num?)?.toInt() ?? 0,
    };

    final meta = res.data['meta'] as Map<String, dynamic>? ?? {};

    return BookingsResponse(
      bookings: bookings,
      stats: stats,
      total: (meta['total'] as num?)?.toInt() ?? bookings.length,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
    );
  }

  /// Fetch active event types
  Future<List<BookingEventTypeModel>> getEventTypes() async {
    final res = await _apiClient.dio.get('/bookings/event-types');
    final List dataList = res.data['data'] as List? ?? [];
    return dataList
        .map((e) => BookingEventTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Query available time slots for an event type
  Future<Map<String, List<BookingSlotModel>>> getSlots({
    required String eventTypeId,
    required String fromDate,
    required String toDate,
    String? timezone,
    String? hostUserId,
  }) async {
    final res = await _apiClient.dio.get('/bookings/slots', queryParameters: {
      'event_type_id': eventTypeId,
      'from': fromDate,
      'to': toDate,
      if (timezone != null) 'timezone': timezone,
      if (hostUserId != null) 'host_user_id': hostUserId,
    });

    final daysMap = res.data['days'] as Map<String, dynamic>? ?? {};
    final result = <String, List<BookingSlotModel>>{};

    daysMap.forEach((dayKey, slotsList) {
      if (slotsList is List) {
        result[dayKey] = slotsList
            .map((s) => BookingSlotModel.fromJson(Map<String, dynamic>.from(s)))
            .toList();
      }
    });

    return result;
  }

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String eventTypeId,
    required DateTime startAt,
    String? hostUserId,
    String? contactId,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? guestCompany,
    String? notes,
    bool createLead = true,
  }) async {
    final res = await _apiClient.dio.post('/bookings', data: {
      'event_type_id': eventTypeId,
      'start_at': startAt.toUtc().toIso8601String(),
      if (hostUserId != null) 'host_user_id': hostUserId,
      if (contactId != null) 'contact_id': contactId,
      if (guestName != null && guestName.isNotEmpty) 'guest_name': guestName,
      if (guestEmail != null && guestEmail.isNotEmpty) 'guest_email': guestEmail,
      if (guestPhone != null && guestPhone.isNotEmpty) 'guest_phone': guestPhone,
      if (guestCompany != null && guestCompany.isNotEmpty) 'guest_company': guestCompany,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'create_lead': createLead,
    });

    return BookingModel.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  /// Get booking details
  Future<BookingModel> getBooking(String id) async {
    final res = await _apiClient.dio.get('/bookings/$id');
    return BookingModel.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  /// Update booking guest information
  Future<BookingModel> updateBooking(String id, {
    required String guestName,
    required String guestEmail,
    String? guestPhone,
    String? guestCompany,
    String? notes,
  }) async {
    final res = await _apiClient.dio.put('/bookings/$id', data: {
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'guest_company': guestCompany,
      if (notes != null) 'notes': notes,
    });

    return BookingModel.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  /// Update booking status (confirmed, completed, cancelled, no_show)
  Future<BookingModel> updateStatus(String id, String status, {String? reason}) async {
    final res = await _apiClient.dio.post('/bookings/$id/status', data: {
      'status': status,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });

    return BookingModel.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  /// Reschedule booking
  Future<BookingModel> reschedule(String id, DateTime newStartAt, {String? reason}) async {
    final res = await _apiClient.dio.post('/bookings/$id/reschedule', data: {
      'start_at': newStartAt.toUtc().toIso8601String(),
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });

    return BookingModel.fromJson(Map<String, dynamic>.from(res.data['data']));
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepository(ref.read(apiClientProvider));
});
