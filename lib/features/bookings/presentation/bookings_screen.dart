import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/models/booking_model.dart';
import 'bookings_provider.dart';
import 'booking_details_sheet.dart';
import 'create_booking_sheet.dart';
import '../../../core/utils/communication_utils.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/app_shimmer.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openCreateBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateBookingSheet(),
    );
  }

  void _openBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingDetailsSheet(booking: booking),
    );
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Appointments & Bookings',
          style: AppTypography.h3(color: isDark ? Colors.white : AppColors.grey900),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarPlus, color: Color(0xFF1B59F8)),
            tooltip: 'Schedule Appointment',
            onPressed: _openCreateBooking,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'bookings_fab',
        backgroundColor: const Color(0xFF1B59F8),
        elevation: 6,
        onPressed: _openCreateBooking,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(bookingsProvider.notifier).loadBookings(refresh: true);
        },
        child: Column(
          children: [
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStatCard('Total', state.stats['total'] ?? 0, const Color(0xFF1B59F8), isDark),
                  const SizedBox(width: 8),
                  _buildStatCard('Upcoming', state.stats['upcoming'] ?? 0, const Color(0xFF10B981), isDark),
                  const SizedBox(width: 8),
                  _buildStatCard('Completed', state.stats['completed'] ?? 0, const Color(0xFF3B82F6), isDark),
                  const SizedBox(width: 8),
                  _buildStatCard('Cancelled', state.stats['cancelled'] ?? 0, const Color(0xFFEF4444), isDark),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search by guest, company, or ref...',
                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(bookingsProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                onChanged: (val) {
                  ref.read(bookingsProvider.notifier).setSearchQuery(val);
                },
              ),
            ),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('All Bookings', 'all', state.selectedStatusFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Upcoming', 'upcoming', state.selectedStatusFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', 'confirmed', state.selectedStatusFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed', state.selectedStatusFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled', state.selectedStatusFilter),
                ],
              ),
            ),

            // Bookings List
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading && state.bookings.isEmpty) {
                    return AppShimmer.cardListShimmer(isDark: isDark);
                  }

                  if (state.errorMessage != null && state.bookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 40),
                          const SizedBox(height: 12),
                          Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref.read(bookingsProvider.notifier).loadBookings(refresh: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.bookings.isEmpty) {
                    return EmptyState(
                      title: 'No Appointments Found',
                      description: state.selectedStatusFilter != 'all'
                          ? 'No ${state.selectedStatusFilter} bookings matching your criteria.'
                          : 'Schedule your first consultation or demo meeting.',
                      icon: LucideIcons.calendarCheck,
                      actionLabel: 'Schedule Appointment',
                      onAction: _openCreateBooking,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final b = state.bookings[index];
                      final statusColor = _getStatusColor(b.status);

                      return InkWell(
                        onTap: () => _openBookingDetails(b),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reference & Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B59F8).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      b.reference,
                                      style: const TextStyle(
                                        color: Color(0xFF1B59F8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      b.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Guest name & Company
                              Text(
                                b.guestName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (b.guestCompany != null && b.guestCompany!.isNotEmpty)
                                Text(
                                  b.guestCompany!,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              const SizedBox(height: 10),

                              // Event Type & Date Time
                              Row(
                                children: [
                                  Icon(
                                    b.meetingUrl != null ? LucideIcons.video : LucideIcons.calendar,
                                    size: 15,
                                    color: const Color(0xFF1B59F8),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${b.eventType?.title ?? 'Appointment'} • ${b.startAt.toString().substring(0, 16)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),

                              // Quick Actions Footer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${b.durationMinutes} min consultation',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                  Row(
                                    children: [
                                      if (b.guestPhone != null && b.guestPhone!.isNotEmpty) ...[
                                        // WhatsApp icon
                                        InkWell(
                                          onTap: () {
                                            final msg = 'Hello ${b.guestName}, regarding our upcoming booking "${b.eventType?.title ?? 'Meeting'}" on ${b.startAt.toString().substring(0, 16)}...';
                                            CommunicationUtils.openWhatsApp(
                                              context: context,
                                              phone: b.guestPhone,
                                              prefilledMessage: msg,
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF25D366).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(LucideIcons.messageSquare, size: 16, color: Color(0xFF25D366)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Call icon
                                        InkWell(
                                          onTap: () {
                                            CommunicationUtils.makeCall(
                                              context: context,
                                              phone: b.guestPhone,
                                              contactName: b.guestName,
                                              ref: ref,
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1B59F8).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(LucideIcons.phoneCall, size: 16, color: Color(0xFF1B59F8)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      // View Details link
                                      const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String current) {
    final isSelected = value == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF1B59F8),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => ref.read(bookingsProvider.notifier).setStatusFilter(value),
    );
  }
}
