import 'package:flutter_test/flutter_test.dart';
import 'package:zetucrm/core/utils/communication_utils.dart';
import 'package:zetucrm/features/bookings/data/models/booking_model.dart';

void main() {
  group('CommunicationUtils.normalizePhone', () {
    test('normalizes standard Tanzanian local 07xx numbers', () {
      expect(CommunicationUtils.normalizePhone('0712345678'), '+255712345678');
      expect(CommunicationUtils.normalizePhone('0655123456'), '+255655123456');
    });

    test('normalizes numbers with spaces, dashes, and parentheses', () {
      expect(CommunicationUtils.normalizePhone('+255 (712) 345-678'), '+255712345678');
      expect(CommunicationUtils.normalizePhone('0712 345 678'), '+255712345678');
    });

    test('normalizes 9-digit numbers without prefix', () {
      expect(CommunicationUtils.normalizePhone('712345678'), '+255712345678');
    });

    test('handles international numbers already with plus prefix', () {
      expect(CommunicationUtils.normalizePhone('+1 (555) 234-5678'), '+15552345678');
      expect(CommunicationUtils.normalizePhone('+254712345678'), '+254712345678');
    });

    test('handles empty and null numbers gracefully', () {
      expect(CommunicationUtils.normalizePhone(null), '');
      expect(CommunicationUtils.normalizePhone(''), '');
    });
  });

  group('CommunicationUtils.forWhatsApp and reminder formatting', () {
    test('extracts digits only for wa.me URL', () {
      expect(CommunicationUtils.forWhatsApp('+255 712-345-678'), '255712345678');
      expect(CommunicationUtils.forWhatsApp('0712345678'), '255712345678');
      expect(CommunicationUtils.forWhatsApp(null), '');
    });

    test('formats booking reminder message correctly as requested', () {
      final msg = CommunicationUtils.formatBookingReminderMessage(
        guestName: 'John Doe',
        eventTitle: 'Product Demo',
        startAt: '2026-10-30 14:00:00.000',
      );
      expect(
        msg,
        'Hello John Doe, regarding our upcoming booking "Product Demo" on 2026-10-30 14:00...',
      );
    });

    test('falls back to "Meeting" when event title is missing or empty', () {
      final msg = CommunicationUtils.formatBookingReminderMessage(
        guestName: 'Jane Smith',
        eventTitle: null,
        startAt: '2026-11-01 09:30:00.000',
      );
      expect(
        msg,
        'Hello Jane Smith, regarding our upcoming booking "Meeting" on 2026-11-01 09:30...',
      );
    });
  });

  group('BookingModel serialization', () {
    test('correctly parses BookingModel from JSON', () {
      final json = {
        'id': '42',
        'reference': 'BK-TEST1234',
        'contact_id': '10',
        'start_at': '2026-10-30T10:00:00.000Z',
        'end_at': '2026-10-30T10:30:00.000Z',
        'status': 'confirmed',
        'guest_name': 'David Machibya',
        'guest_email': 'david@example.com',
        'guest_phone': '+255712345678',
        'guest_company': 'Zetu Tech',
        'meeting_url': 'https://meet.google.com/abc-defg-hij',
        'location': 'google_meet',
        'event_type': {
          'id': '1',
          'title': 'Demo Call',
          'duration_minutes': 30,
          'color': '#1B59F8',
        },
      };

      final booking = BookingModel.fromJson(json);
      expect(booking.id, '42');
      expect(booking.reference, 'BK-TEST1234');
      expect(booking.status, 'confirmed');
      expect(booking.guestPhone, '+255712345678');
      expect(booking.eventType?.title, 'Demo Call');
      expect(booking.eventType?.durationMinutes, 30);
      expect(booking.isConfirmed, isTrue);
      expect(booking.isCancelled, isFalse);
    });

    test('correctly parses BookingSlotModel from JSON', () {
      final json = {
        'start': '2026-10-30T09:00:00.000Z',
        'end': '2026-10-30T09:30:00.000Z',
        'start_utc': '2026-10-30 09:00:00',
        'end_utc': '2026-10-30 09:30:00',
        'time_label': '09:00 AM',
        'end_time_label': '09:30 AM',
        'available_hosts_count': 2,
        'host_ids': ['1', '2'],
      };

      final slot = BookingSlotModel.fromJson(json);
      expect(slot.timeLabel, '09:00 AM');
      expect(slot.endTimeLabel, '09:30 AM');
      expect(slot.availableHostsCount, 2);
      expect(slot.hostIds, contains('1'));
    });
  });
}
