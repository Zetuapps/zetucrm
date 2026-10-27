import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'notifications_provider.dart';
import '../../features/bookings/data/bookings_repository.dart';
import '../../features/bookings/presentation/booking_details_sheet.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  static Future<void> showAsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: NotificationsScreen(),
      ),
    );
  }

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'all'; // all, unread, reminders, reports

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter notifications based on selected filter tab
    final filtered = state.notifications.where((n) {
      if (_selectedFilter == 'unread') {
        return !n.isRead;
      } else if (_selectedFilter == 'reminders') {
        return n.type.contains('reminder') || n.type.contains('task');
      } else if (_selectedFilter == 'reports') {
        return n.type.contains('report') || n.type.contains('financial');
      }
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10141D) : const Color(0xFFF8F9FC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF101828),
                      ),
                    ),
                    if (state.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B59F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.unreadCount} new',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (state.unreadCount > 0)
                      TextButton.icon(
                        onPressed: () => notifier.markAllAsRead(),
                        icon: const Icon(LucideIcons.checkCheck, size: 16),
                        label: const Text(
                          'Mark read',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1B59F8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: isDark ? Colors.white70 : const Color(0xFF667085),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', 'All (${state.notifications.length})', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('unread', 'Unread (${state.unreadCount})', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('reminders', 'Reminders', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('reports', 'Reports', isDark),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notification List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.loadNotifications(),
              child: state.isLoading && state.notifications.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF1B59F8),
                      ),
                    )
                  : filtered.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final notification = filtered[index];
                            return _buildNotificationCard(
                              notification,
                              isDark,
                              notifier,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B59F8)
              : (isDark ? const Color(0xFF1A2234) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFE4E7EC),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF475467)),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    bool isDark,
    NotificationsNotifier notifier,
  ) {
    final isRead = notification.isRead;
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
      ),
      onDismissed: (_) {
        notifier.deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () async {
          if (!isRead) {
            notifier.markAsRead(notification.id);
          }
          final bookingId = notification.data['booking_id']?.toString();
          if (bookingId != null && bookingId.isNotEmpty) {
            try {
              final repo = ref.read(bookingsRepositoryProvider);
              final booking = await repo.getBooking(bookingId);
              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BookingDetailsSheet(booking: booking),
                );
              }
            } catch (_) {}
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? (isRead ? const Color(0xFF161C28) : const Color(0xFF1D2638))
                : (isRead ? Colors.white : const Color(0xFFF2F6FF)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: !isRead
                  ? const Color(0xFF1B59F8).withOpacity(0.3)
                  : (isDark ? Colors.white10 : const Color(0xFFEAECF0)),
              width: !isRead ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF101828),
                            ),
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B59F8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : const Color(0xFF475467),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatRelativeTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D2638) : const Color(0xFFEFF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bellOff,
                size: 28,
                color: Color(0xFF1B59F8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedFilter == 'unread'
                  ? 'You are all caught up! No unread notifications right now.'
                  : 'You will receive reminders, task updates, and financial reports right here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white60 : const Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    if (type.contains('booking')) {
      return LucideIcons.calendar;
    } else if (type.contains('task')) {
      return LucideIcons.checkSquare;
    } else if (type.contains('scorecard')) {
      return LucideIcons.target;
    } else if (type.contains('report') || type.contains('financial')) {
      return LucideIcons.landmark;
    } else if (type.contains('invitation')) {
      return LucideIcons.userPlus;
    } else if (type.contains('email')) {
      return LucideIcons.mail;
    }
    return LucideIcons.bell;
  }

  Color _getNotificationColor(String type) {
    if (type.contains('booking')) {
      return const Color(0xFF0284C7); // Sky blue
    } else if (type.contains('task')) {
      return const Color(0xFF1B59F8); // Blue
    } else if (type.contains('scorecard')) {
      return const Color(0xFFF79009); // Amber
    } else if (type.contains('report') || type.contains('financial')) {
      return const Color(0xFF12B76A); // Emerald
    } else if (type.contains('invitation')) {
      return const Color(0xFF7A5AF8); // Purple
    } else if (type.contains('email')) {
      return const Color(0xFF0086C9); // Cyan
    }
    return const Color(0xFF1B59F8);
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
