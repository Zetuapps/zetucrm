class BookingModel {
  final String id;
  final String reference;
  final String? eventTypeId;
  final String? hostUserId;
  final String? contactId;
  final String? dealId;
  final DateTime startAt;
  final DateTime endAt;
  final String guestName;
  final String guestEmail;
  final String? guestPhone;
  final String? guestCompany;
  final String status; // confirmed, completed, cancelled, no_show
  final String? meetingUrl;
  final String? location;
  final String? cancelReason;
  final Map<String, dynamic> answers;
  final BookingEventTypeSummary? eventType;
  final BookingHostSummary? host;
  final BookingContactSummary? contact;

  BookingModel({
    required this.id,
    required this.reference,
    this.eventTypeId,
    this.hostUserId,
    this.contactId,
    this.dealId,
    required this.startAt,
    required this.endAt,
    required this.guestName,
    required this.guestEmail,
    this.guestPhone,
    this.guestCompany,
    required this.status,
    this.meetingUrl,
    this.location,
    this.cancelReason,
    this.answers = const {},
    this.eventType,
    this.host,
    this.contact,
  });

  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isUpcoming => isConfirmed && startAt.isAfter(DateTime.now());

  int get durationMinutes => endAt.difference(startAt).inMinutes;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      eventTypeId: json['event_type_id']?.toString(),
      hostUserId: json['host_user_id']?.toString(),
      contactId: json['contact_id']?.toString(),
      dealId: json['deal_id']?.toString(),
      startAt: json['start_at'] != null
          ? DateTime.tryParse(json['start_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      endAt: json['end_at'] != null
          ? DateTime.tryParse(json['end_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      guestName: json['guest_name']?.toString() ?? 'Guest',
      guestEmail: json['guest_email']?.toString() ?? '',
      guestPhone: json['guest_phone']?.toString(),
      guestCompany: json['guest_company']?.toString(),
      status: json['status']?.toString() ?? 'confirmed',
      meetingUrl: json['meeting_url']?.toString(),
      location: json['location']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      answers: json['answers'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['answers'])
          : {},
      eventType: json['event_type'] is Map<String, dynamic>
          ? BookingEventTypeSummary.fromJson(Map<String, dynamic>.from(json['event_type']))
          : null,
      host: json['host'] is Map<String, dynamic>
          ? BookingHostSummary.fromJson(Map<String, dynamic>.from(json['host']))
          : null,
      contact: json['contact'] is Map<String, dynamic>
          ? BookingContactSummary.fromJson(Map<String, dynamic>.from(json['contact']))
          : null,
    );
  }
}

class BookingEventTypeSummary {
  final String id;
  final String title;
  final String slug;
  final int durationMinutes;
  final String? locationType;

  BookingEventTypeSummary({
    required this.id,
    required this.title,
    required this.slug,
    required this.durationMinutes,
    this.locationType,
  });

  factory BookingEventTypeSummary.fromJson(Map<String, dynamic> json) {
    return BookingEventTypeSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Meeting',
      slug: json['slug']?.toString() ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
      locationType: json['location_type']?.toString(),
    );
  }
}

class BookingHostSummary {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;

  BookingHostSummary({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  String get displayName => [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');

  factory BookingHostSummary.fromJson(Map<String, dynamic> json) {
    return BookingHostSummary(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class BookingContactSummary {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? company;

  BookingContactSummary({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.company,
  });

  String get displayName => [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');

  factory BookingContactSummary.fromJson(Map<String, dynamic> json) {
    return BookingContactSummary(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      company: json['company']?.toString(),
    );
  }
}

class BookingEventTypeModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final int durationMinutes;
  final int bookingWindowDays;
  final String locationType;
  final bool isActive;
  final List<BookingHostSummary> hosts;

  BookingEventTypeModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.durationMinutes,
    required this.bookingWindowDays,
    required this.locationType,
    this.isActive = true,
    this.hosts = const [],
  });

  factory BookingEventTypeModel.fromJson(Map<String, dynamic> json) {
    final hostsList = json['hosts'] as List? ?? [];
    return BookingEventTypeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
      bookingWindowDays: (json['booking_window_days'] as num?)?.toInt() ?? 14,
      locationType: json['location_type']?.toString() ?? 'google_meet',
      isActive: json['is_active'] == true,
      hosts: hostsList
          .map((h) => BookingHostSummary.fromJson(
                h['user'] is Map<String, dynamic>
                    ? Map<String, dynamic>.from(h['user'])
                    : Map<String, dynamic>.from(h),
              ))
          .toList(),
    );
  }
}

class BookingSlotModel {
  final DateTime start;
  final DateTime end;
  final String startUtc;
  final String endUtc;
  final String timeLabel;
  final String endTimeLabel;
  final int availableHostsCount;
  final List<String> hostIds;

  BookingSlotModel({
    required this.start,
    required this.end,
    required this.startUtc,
    required this.endUtc,
    required this.timeLabel,
    required this.endTimeLabel,
    required this.availableHostsCount,
    required this.hostIds,
  });

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      start: DateTime.tryParse(json['start'].toString())?.toLocal() ?? DateTime.now(),
      end: DateTime.tryParse(json['end'].toString())?.toLocal() ?? DateTime.now(),
      startUtc: json['start_utc']?.toString() ?? '',
      endUtc: json['end_utc']?.toString() ?? '',
      timeLabel: json['time_label']?.toString() ?? '',
      endTimeLabel: json['end_time_label']?.toString() ?? '',
      availableHostsCount: (json['available_hosts_count'] as num?)?.toInt() ?? 1,
      hostIds: (json['host_ids'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
