import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_provider.dart';

class CommunicationUtils {
  /// Clean and format a phone number to standard international format (E.164-ish).
  /// Handles local Tanzanian format (07... or 06...) -> +2557..., +2556...
  static String normalizePhone(String? rawPhone) {
    if (rawPhone == null) return '';
    String cleaned = rawPhone.trim();

    // Strip spaces, dashes, parentheses
    cleaned = cleaned.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    // Handle local Tanzanian format: 07xx or 06xx -> +2557xx
    if (cleaned.startsWith('0') && cleaned.length >= 10) {
      cleaned = '+255${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+') && cleaned.startsWith('255')) {
      cleaned = '+$cleaned';
    } else if (!cleaned.startsWith('+') && cleaned.length == 9) {
      // 7xxxxxxxx -> +2557xxxxxxxx
      cleaned = '+255$cleaned';
    }

    return cleaned;
  }

  /// Strip everything except digits for WhatsApp wa.me link (WhatsApp requires digits only, no +)
  static String forWhatsApp(String? rawPhone) {
    final normalized = normalizePhone(rawPhone);
    return normalized.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Launch WhatsApp chat directly without requiring BuildContext
  /// Ideal for push notification clicks or background event dispatching
  static Future<bool> launchWhatsAppDirect(String? phone, String? prefilledMessage) async {
    final cleanDigits = forWhatsApp(phone);
    if (cleanDigits.length < 8) return false;

    String urlStr = 'https://wa.me/$cleanDigits';
    if (prefilledMessage != null && prefilledMessage.trim().isNotEmpty) {
      urlStr += '?text=${Uri.encodeComponent(prefilledMessage.trim())}';
    }

    final uri = Uri.parse(urlStr);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Format standard WhatsApp reminder message for upcoming meetings / bookings:
  /// 'Hello ${b.guestName}, regarding our upcoming booking "${b.eventType?.title ?? 'Meeting'}" on ${b.startAt.toString().substring(0, 16)}...'
  static String formatBookingReminderMessage({
    required String guestName,
    String? eventTitle,
    required String startAt,
  }) {
    final title = (eventTitle != null && eventTitle.trim().isNotEmpty) ? eventTitle : 'Meeting';
    final formattedTime = startAt.length >= 16 ? startAt.substring(0, 16) : startAt;
    return 'Hello $guestName, regarding our upcoming booking "$title" on $formattedTime...';
  }

  /// Launch WhatsApp chat with validated phone and optional pre-filled message
  static Future<bool> openWhatsApp({
    required BuildContext context,
    required String? phone,
    String? prefilledMessage,
  }) async {
    final cleanDigits = forWhatsApp(phone);
    if (cleanDigits.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or missing phone number for WhatsApp'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    String urlStr = 'https://wa.me/$cleanDigits';
    if (prefilledMessage != null && prefilledMessage.trim().isNotEmpty) {
      urlStr += '?text=${Uri.encodeComponent(prefilledMessage.trim())}';
    }

    final uri = Uri.parse(urlStr);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Ensure WhatsApp is installed.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return launched;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching WhatsApp: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Launch native dialer to place a call
  static Future<bool> makeCall({
    required BuildContext context,
    required String? phone,
    String? contactName,
    String? contactId,
    WidgetRef? ref,
  }) async {
    final normalized = normalizePhone(phone);
    if (normalized.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or missing phone number for calling'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    final uri = Uri.parse('tel:$normalized');
    try {
      final launched = await launchUrl(uri);
      if (launched && ref != null && context.mounted && contactId != null) {
        // Offer quick outcome logger after placing a call
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            _showCallLogDialog(context, ref, contactId, contactName ?? 'Contact', normalized);
          }
        });
      }
      return launched;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing call: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Dialog to record call outcome and notes in CRM
  static void _showCallLogDialog(
    BuildContext context,
    WidgetRef ref,
    String contactId,
    String contactName,
    String phone,
  ) {
    String outcome = 'connected';
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log Call: $contactName',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text('Phone: $phone', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: outcome,
                  decoration: const InputDecoration(
                    labelText: 'Call Outcome',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'connected', child: Text('Connected / Spoke with contact')),
                    DropdownMenuItem(value: 'busy', child: Text('Busy line')),
                    DropdownMenuItem(value: 'no_answer', child: Text('No answer')),
                    DropdownMenuItem(value: 'left_voicemail', child: Text('Left voicemail / message')),
                    DropdownMenuItem(value: 'wrong_number', child: Text('Wrong number')),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheetState(() => outcome = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Call Notes / Discussion Summary',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B59F8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final apiClient = ref.read(apiClientProvider);
                        await apiClient.dio.post('/activities', data: {
                          'contact_id': contactId,
                          'type': 'call',
                          'direction': 'outbound',
                          'subject': 'Phone call with $contactName',
                          'outcome': outcome,
                          'description': notesCtrl.text.trim(),
                          'is_completed': true,
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Call activity recorded in CRM'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (_) {
                        // Offline queue fallback
                      }
                    },
                    child: const Text('Save Call Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
