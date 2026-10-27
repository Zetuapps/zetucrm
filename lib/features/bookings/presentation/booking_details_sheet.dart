import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/models/booking_model.dart';
import 'bookings_provider.dart';
import '../../../core/utils/communication_utils.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BookingDetailsSheet extends ConsumerStatefulWidget {
  final BookingModel booking;

  const BookingDetailsSheet({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailsSheet> createState() =>
      _BookingDetailsSheetState();
}

class _BookingDetailsSheetState extends ConsumerState<BookingDetailsSheet> {
  late BookingModel _currentBooking;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'no_show':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _promptCancelBooking() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking? This will free the slot for other clients.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                hintText: 'e.g. Client requested cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isProcessing = true);
              try {
                await ref
                    .read(bookingsProvider.notifier)
                    .updateStatus(
                      _currentBooking.id,
                      'cancelled',
                      reason: reasonCtrl.text.trim(),
                    );
                setState(() {
                  _currentBooking = BookingModel(
                    id: _currentBooking.id,
                    reference: _currentBooking.reference,
                    startAt: _currentBooking.startAt,
                    endAt: _currentBooking.endAt,
                    guestName: _currentBooking.guestName,
                    guestEmail: _currentBooking.guestEmail,
                    guestPhone: _currentBooking.guestPhone,
                    guestCompany: _currentBooking.guestCompany,
                    status: 'cancelled',
                    cancelReason: reasonCtrl.text.trim(),
                    meetingUrl: _currentBooking.meetingUrl,
                    location: _currentBooking.location,
                    answers: _currentBooking.answers,
                    eventType: _currentBooking.eventType,
                    host: _currentBooking.host,
                    contact: _currentBooking.contact,
                  );
                  _isProcessing = false;
                });
                _showSnack('Appointment cancelled successfully');
              } catch (e) {
                setState(() => _isProcessing = false);
                _showSnack('Failed to cancel: $e', isError: true);
              }
            },
            child: const Text(
              'Confirm Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _promptReschedule() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentBooking.startAt.isAfter(DateTime.now())
          ? _currentBooking.startAt
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_currentBooking.startAt),
      );

      if (pickedTime != null && mounted) {
        final newStart = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() => _isProcessing = true);
        try {
          await ref
              .read(bookingsProvider.notifier)
              .reschedule(
                _currentBooking.id,
                newStart,
                reason: 'Rescheduled by host via mobile app',
              );
          setState(() {
            _currentBooking = BookingModel(
              id: _currentBooking.id,
              reference: _currentBooking.reference,
              startAt: newStart,
              endAt: newStart.add(
                Duration(minutes: _currentBooking.durationMinutes),
              ),
              guestName: _currentBooking.guestName,
              guestEmail: _currentBooking.guestEmail,
              guestPhone: _currentBooking.guestPhone,
              guestCompany: _currentBooking.guestCompany,
              status: 'confirmed',
              meetingUrl: _currentBooking.meetingUrl,
              location: _currentBooking.location,
              answers: _currentBooking.answers,
              eventType: _currentBooking.eventType,
              host: _currentBooking.host,
              contact: _currentBooking.contact,
            );
            _isProcessing = false;
          });
          _showSnack(
            'Appointment rescheduled to ${newStart.toString().substring(0, 16)}',
          );
        } catch (e) {
          setState(() => _isProcessing = false);
          _showSnack('Failed to reschedule: $e', isError: true);
        }
      }
    }
  }

  void _markCompleted() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(bookingsProvider.notifier)
          .updateStatus(_currentBooking.id, 'completed');
      setState(() {
        _currentBooking = BookingModel(
          id: _currentBooking.id,
          reference: _currentBooking.reference,
          startAt: _currentBooking.startAt,
          endAt: _currentBooking.endAt,
          guestName: _currentBooking.guestName,
          guestEmail: _currentBooking.guestEmail,
          guestPhone: _currentBooking.guestPhone,
          guestCompany: _currentBooking.guestCompany,
          status: 'completed',
          meetingUrl: _currentBooking.meetingUrl,
          location: _currentBooking.location,
          answers: _currentBooking.answers,
          eventType: _currentBooking.eventType,
          host: _currentBooking.host,
          contact: _currentBooking.contact,
        );
        _isProcessing = false;
      });
      _showSnack('Appointment marked as completed');
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnack('Failed to update status: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final b = _currentBooking;
    final statusColor = _getStatusColor(b.status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.reference,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    b.eventType?.title ?? 'Appointment',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  b.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Body Scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.calendar,
                              size: 18,
                              color: Color(0xFF1B59F8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              b.startAt.toString().substring(0, 10),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1B59F8,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${b.durationMinutes} min',
                                style: const TextStyle(
                                  color: Color(0xFF1B59F8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.clock,
                              size: 18,
                              color: Color(0xFF1B59F8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${b.startAt.toString().substring(11, 16)} - ${b.endAt.toString().substring(11, 16)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (b.meetingUrl != null &&
                            b.meetingUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => launchUrl(
                              Uri.parse(b.meetingUrl!),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.video,
                                    size: 16,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Join Google Meet Video Call',
                                    style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    LucideIcons.externalLink,
                                    size: 13,
                                    color: Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Guest / Client Info Card
                  Text(
                    'Guest / Client Details',
                    style: AppTypography.subtitle2(
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(
                                0xFF1B59F8,
                              ).withValues(alpha: 0.15),
                              child: Text(
                                b.guestName.isNotEmpty
                                    ? b.guestName[0].toUpperCase()
                                    : 'G',
                                style: const TextStyle(
                                  color: Color(0xFF1B59F8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.guestName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (b.guestCompany != null &&
                                      b.guestCompany!.isNotEmpty)
                                    Text(
                                      b.guestCompany!,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (b.guestEmail.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.mail,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b.guestEmail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (b.guestPhone != null &&
                            b.guestPhone!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.phone,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b.guestPhone!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              // Quick WhatsApp button
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                // icon: const Icon(LucideIcons.messageSquare, color: Color(0xFF25D366), size: 20),

                                //                                child: const FaIcon(
                                //   FontAwesomeIcons.whatsapp,
                                //   size: 16,
                                //   color: Color(0xFF25D366),
                                // ),
                                icon: const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Color(0xFF25D366),
                                  size: 20,
                                ),
                                tooltip: 'WhatsApp Client',
                                onPressed: () {
                                  final msg =
                                      'Hello ${b.guestName}, regarding our upcoming booking "${b.eventType?.title ?? 'Meeting'}" on ${b.startAt.toString().substring(0, 16)}...';
                                  CommunicationUtils.openWhatsApp(
                                    context: context,
                                    phone: b.guestPhone,
                                    prefilledMessage: msg,
                                  );
                                },
                              ),
                              // Quick Call button
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                icon: const Icon(
                                  LucideIcons.phoneCall,
                                  color: Color(0xFF1B59F8),
                                  size: 20,
                                ),
                                tooltip: 'Call Client',
                                onPressed: () {
                                  CommunicationUtils.makeCall(
                                    context: context,
                                    phone: b.guestPhone,
                                    contactName: b.guestName,
                                    ref: ref,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Host Details
                  if (b.host != null) ...[
                    Text(
                      'Assigned Host',
                      style: AppTypography.subtitle2(
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.purple.withValues(alpha: 0.15),
                        child: const Icon(
                          LucideIcons.user,
                          size: 16,
                          color: Colors.purple,
                        ),
                      ),
                      title: Text(
                        b.host!.displayName.isNotEmpty
                            ? b.host!.displayName
                            : 'Assigned Team Member',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        b.host!.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Notes / Answers
                  if (b.answers.isNotEmpty) ...[
                    Text(
                      'Meeting Notes & Answers',
                      style: AppTypography.subtitle2(
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        b.answers['notes']?.toString() ?? b.answers.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (b.cancelReason != null && b.cancelReason!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cancellation Reason',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.cancelReason!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Action Buttons Bar
          const SizedBox(height: 12),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator())
          else if (b.isConfirmed) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.xCircle, size: 16),
                    label: const Text('Cancel'),
                    onPressed: _promptCancelBooking,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B59F8),
                      side: const BorderSide(color: Color(0xFF1B59F8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.calendarDays, size: 16),
                    label: const Text('Reschedule'),
                    onPressed: _promptReschedule,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(
                      LucideIcons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Complete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _markCompleted,
                  ),
                ),
              ],
            ),
          ] else if (b.isCancelled) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B59F8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(
                  LucideIcons.calendarCheck,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Re-schedule / Re-confirm Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _promptReschedule,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
