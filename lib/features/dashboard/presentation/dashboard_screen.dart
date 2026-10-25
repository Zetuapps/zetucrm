import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/sync/sync_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/components/unified_form.dart';
import '../../finance/presentation/finance_screen.dart';
import '../../finance/presentation/sheets/expense_form_sheet.dart';
import '../../finance/presentation/sheets/requisition_form_sheet.dart';
import 'dashboard_provider.dart';
import '../../../core/notifications/notifications_provider.dart';
import '../../../core/notifications/notifications_screen.dart';
import 'package:drift/drift.dart' hide Column;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRange = ref.watch(selectedRangeProvider);
    final dashboardAsync = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.firstName ?? 'User';
    final notifState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10141D) : const Color(0xFFF7F9FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            await ref.read(syncProvider.notifier).pullAllInitialData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Header
                _buildTopAppBar(context, isDark, userName, notifState.unreadCount),
                const SizedBox(height: 24),

                // Main Reactive Body handling API AsyncValue
                dashboardAsync.when(
                  loading: () => _buildLoadingState(isDark),
                  error: (err, stack) => _buildErrorState(err.toString(), isDark),
                  data: (data) => _buildDashboardContent(context, data, selectedRange, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, bool isDark, String userName, int unreadCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1B59F8),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B59F8).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),

        // Action Buttons
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIconButton(
                  icon: LucideIcons.bell,
                  isDark: isDark,
                  onTap: () {
                    NotificationsScreen.showAsBottomSheet(context);
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE63946),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            _buildIconButton(
              icon: LucideIcons.moreHorizontal,
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Color(0xFF1B59F8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2538) : const Color(0xFFEEF2F6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white70 : const Color(0xFF475467),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardData data,
    String selectedRange,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Horizontal Scrollable Top Metric Cards
        SizedBox(
          height: 125,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTopScrollCard(
                title: 'New Leads',
                value: '${data.newLeads.count}+',
                change: data.newLeads.change,
                icon: LucideIcons.layoutGrid,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildTopScrollCard(
                title: 'Customer Network',
                value: '${data.customerNetwork.count}+',
                change: data.customerNetwork.change,
                icon: LucideIcons.layers,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildTopScrollCard(
                title: 'Deals Pipeline',
                value: '\$${(data.pipelineValue / 1000).toStringAsFixed(1)}K',
                change: data.deals.change,
                icon: LucideIcons.trendingUp,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 2. Overview Section Header & Dropdown Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overview',
              style: AppTypography.h2(
                color: isDark ? Colors.white : const Color(0xFF101828),
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            PopupMenuButton<String>(
              initialValue: selectedRange,
              onSelected: (val) {
                ref.read(selectedRangeProvider.notifier).setRange(val);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2538) : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedRange,
                      style: AppTypography.caption(
                        color: isDark ? Colors.white70 : const Color(0xFF475467),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF475467),
                    ),
                  ],
                ),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
                PopupMenuItem(value: 'This Month', child: Text('This Month')),
                PopupMenuItem(value: '3 Months', child: Text('3 Months')),
                PopupMenuItem(value: 'Year', child: Text('Year')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. Overview 2 Main Cards (Deals & Customers)
        Row(
          children: [
            // Left Card: Solid Blue
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B59F8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B59F8).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(LucideIcons.user, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Deals',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${data.deals.count}+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.arrowUp, size: 11, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                '${data.deals.change.abs()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'vs last month',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Right Card: Clean Surface
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2234) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2B344B) : const Color(0xFFF2F4F7),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.user,
                          size: 16,
                          color: isDark ? Colors.white70 : const Color(0xFF475467),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Customers',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF475467),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${data.customers.count}+',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE4E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.arrowDown, size: 11, color: Color(0xFFD92D20)),
                              const SizedBox(width: 2),
                              Text(
                                '${data.customers.change.abs()}%',
                                style: const TextStyle(
                                  color: Color(0xFFD92D20),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'vs last month',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // 4. "10 Customers / Leads Today" Section (Priority Sorted: Tasks Due -> Activity -> Saved Today)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '10 Leads & Customers Today',
              style: AppTypography.body1(
                color: isDark ? Colors.white : const Color(0xFF101828),
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Priority Ranked',
              style: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFF667085),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 95,
          child: data.todayNewContacts.isEmpty
              ? Text(
                  'No active leads or tasks for today.',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.todayNewContacts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, idx) {
                    final item = data.todayNewContacts[idx];
                    Color badgeColor = const Color(0xFF12B76A);
                    if (item.priority == 1) badgeColor = const Color(0xFFD92D20); // Task due
                    if (item.priority == 2) badgeColor = const Color(0xFF1B59F8); // Activity

                    return Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF1B59F8).withOpacity(0.12),
                              child: Text(
                                item.initial,
                                style: const TextStyle(
                                  color: Color(0xFF1B59F8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.shortName,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF344054),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),

        // 5. Quick Actions Section
        Text(
          'Quick Actions',
          style: AppTypography.h3(
            color: isDark ? Colors.white : const Color(0xFF101828),
          ).copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),

        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            _buildQuickActionButton(
              label: 'New Lead',
              icon: LucideIcons.userPlus,
              isDark: isDark,
              onTap: () => _showNewLeadSheet(context),
            ),
            _buildQuickActionButton(
              label: '+ Expense',
              icon: LucideIcons.receipt,
              isDark: isDark,
              onTap: () => ExpenseFormSheet.show(context),
            ),
            _buildQuickActionButton(
              label: 'Requisition',
              icon: LucideIcons.filePlus,
              isDark: isDark,
              onTap: () => RequisitionFormSheet.show(context),
            ),
            _buildQuickActionButton(
              label: 'Finance Hub',
              icon: LucideIcons.landmark,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinanceScreen()),
              ),
            ),
            _buildQuickActionButton(
              label: 'Add Note',
              icon: LucideIcons.fileText,
              isDark: isDark,
              onTap: () => _showAddNoteSheet(context),
            ),
            _buildQuickActionButton(
              label: 'Send Email',
              icon: LucideIcons.mail,
              isDark: isDark,
              onTap: () => _showSendEmailSheet(context),
            ),
            _buildQuickActionButton(
              label: 'Log Activity',
              icon: LucideIcons.messageSquare,
              isDark: isDark,
              onTap: () => _showLogActivitySheet(context),
            ),
            _buildQuickActionButton(
              label: 'Ledger',
              icon: LucideIcons.bookOpen,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinanceScreen(initialTabIndex: 2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // 6. TASKS DUE TODAY SECTION (Clean modern dashboard card)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks Due Today',
              style: AppTypography.h3(
                color: isDark ? Colors.white : const Color(0xFF101828),
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1B59F8).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${data.tasksDueToday.length} Pending',
                style: const TextStyle(
                  color: Color(0xFF1B59F8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (data.tasksDueToday.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2234) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '🎉 No pending tasks due today!',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.tasksDueToday.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final task = data.tasksDueToday[idx];
              Color priorityColor = const Color(0xFF12B76A);
              if (task.priority == 'high' || task.priority == 'urgent') {
                priorityColor = const Color(0xFFD92D20);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2234) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2B344B) : const Color(0xFFEAECF0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      size: 20,
                      color: isDark ? Colors.white38 : const Color(0xFFD0D5DD),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF101828),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (task.contactName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Lead: ${task.contactName}',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : const Color(0xFF667085),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.dueTime,
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 28),
      ],
    );
  }

  // Quick Action Forms Implementation using UnifiedFormSheet
  void _showNewLeadSheet(BuildContext context) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final companyCtrl = TextEditingController();

    UnifiedFormSheet.show(
      context: context,
      title: 'Add New Lead',
      subtitle: 'Create a new contact record in CRM',
      submitLabel: 'Create Lead',
      onSubmit: () async {
        if (firstNameCtrl.text.trim().isEmpty) return;
        final db = ref.read(databaseProvider);
        await db.into(db.contactsTable).insert(
              ContactsTableCompanion.insert(
                firstName: firstNameCtrl.text.trim(),
                lastName: Value(lastNameCtrl.text.trim()),
                phone: Value(phoneCtrl.text.trim()),
                email: Value(emailCtrl.text.trim()),
                company: Value(companyCtrl.text.trim()),
                localUpdatedAt: DateTime.now(),
              ),
            );
        ref.invalidate(dashboardProvider);
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Lead saved successfully')),
        );
      },
      child: Column(
        children: [
          UnifiedTextField(label: 'First Name *', controller: firstNameCtrl, hint: 'e.g. Alex'),
          UnifiedTextField(label: 'Last Name', controller: lastNameCtrl, hint: 'e.g. Morgan'),
          UnifiedTextField(label: 'Phone Number', controller: phoneCtrl, hint: '+1 555 0192', keyboardType: TextInputType.phone),
          UnifiedTextField(label: 'Email Address', controller: emailCtrl, hint: 'alex@company.com', keyboardType: TextInputType.emailAddress),
          UnifiedTextField(label: 'Company Name', controller: companyCtrl, hint: 'Acme Corp'),
        ],
      ),
    );
  }

  void _showAddNoteSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    UnifiedFormSheet.show(
      context: context,
      title: 'Add Lead Note',
      subtitle: 'Record internal notes or discussion updates',
      submitLabel: 'Save Note',
      onSubmit: () async {
        if (noteCtrl.text.trim().isEmpty) return;
        final db = ref.read(databaseProvider);
        await db.into(db.activitiesTable).insert(
              ActivitiesTableCompanion.insert(
                type: 'note',
                subject: Value(titleCtrl.text.trim().isEmpty ? 'Note Entry' : titleCtrl.text.trim()),
                description: Value(noteCtrl.text.trim()),
                localUpdatedAt: DateTime.now(),
              ),
            );
        ref.invalidate(dashboardProvider);
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
        );
      },
      child: Column(
        children: [
          UnifiedTextField(label: 'Note Subject', controller: titleCtrl, hint: 'e.g. Budget Discussion'),
          UnifiedTextField(label: 'Note Details *', controller: noteCtrl, hint: 'Enter notes...', maxLines: 4),
        ],
      ),
    );
  }

  void _showSendEmailSheet(BuildContext context) {
    final toCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    UnifiedFormSheet.show(
      context: context,
      title: 'Send Email',
      subtitle: 'Send direct email to lead or customer',
      submitLabel: 'Send & Log Email',
      onSubmit: () async {
        if (toCtrl.text.trim().isEmpty) return;
        final db = ref.read(databaseProvider);
        await db.into(db.activitiesTable).insert(
              ActivitiesTableCompanion.insert(
                type: 'email',
                subject: Value(subjectCtrl.text.trim().isEmpty ? 'Outbound Email' : subjectCtrl.text.trim()),
                description: Value('Sent to: ${toCtrl.text.trim()}\n${bodyCtrl.text.trim()}'),
                localUpdatedAt: DateTime.now(),
              ),
            );
        ref.invalidate(dashboardProvider);
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email logged successfully')),
        );
      },
      child: Column(
        children: [
          UnifiedTextField(label: 'To Email *', controller: toCtrl, hint: 'client@company.com', keyboardType: TextInputType.emailAddress),
          UnifiedTextField(label: 'Subject', controller: subjectCtrl, hint: 'Proposal Review'),
          UnifiedTextField(label: 'Message Body', controller: bodyCtrl, hint: 'Hi Alex, following up on...', maxLines: 4),
        ],
      ),
    );
  }

  void _showLogActivitySheet(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    String activityType = 'call';

    UnifiedFormSheet.show(
      context: context,
      title: 'Log Activity',
      subtitle: 'Log a call, meeting, or touchpoint',
      submitLabel: 'Log Touchpoint',
      onSubmit: () async {
        if (subjectCtrl.text.trim().isEmpty) return;
        final db = ref.read(databaseProvider);
        await db.into(db.activitiesTable).insert(
              ActivitiesTableCompanion.insert(
                type: activityType,
                subject: Value(subjectCtrl.text.trim()),
                description: Value(detailsCtrl.text.trim()),
                localUpdatedAt: DateTime.now(),
              ),
            );
        ref.invalidate(dashboardProvider);
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity logged successfully')),
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              UnifiedDropdownField<String>(
                label: 'Activity Type',
                value: activityType,
                items: const [
                  DropdownMenuItem(value: 'call', child: Text('Phone Call')),
                  DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Message')),
                  DropdownMenuItem(value: 'email', child: Text('Email Touchpoint')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => activityType = val);
                },
              ),
              UnifiedTextField(label: 'Subject *', controller: subjectCtrl, hint: 'e.g. Discovery Call with Alex'),
              UnifiedTextField(label: 'Outcome / Notes', controller: detailsCtrl, hint: 'Discussed timeline & pricing...', maxLines: 3),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopScrollCard({
    required String title,
    required String value,
    required double change,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2234) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2B344B) : const Color(0xFFF2F4F7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                LucideIcons.moreHorizontal,
                size: 16,
                color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B59F8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF1B59F8)),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(LucideIcons.arrowUpRight, size: 12, color: Color(0xFF12B76A)),
              const SizedBox(width: 4),
              Text(
                '+${change.abs()}% increase',
                style: const TextStyle(
                  color: Color(0xFF12B76A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2234) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2B344B) : const Color(0xFFEAECF0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1B59F8),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B59F8).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF344054),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Color(0xFF1B59F8)),
            const SizedBox(height: 16),
            Text(
              'Loading live CRM data...',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMsg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1C1D) : const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertTriangle, size: 42, color: Color(0xFFD92D20)),
          const SizedBox(height: 12),
          const Text(
            'Failed to fetch API data',
            style: TextStyle(
              color: Color(0xFFB42318),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMsg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFFB42318),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B59F8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref.invalidate(dashboardProvider);
            },
            icon: const Icon(LucideIcons.refreshCw, size: 16, color: Colors.white),
            label: const Text('Retry Connection', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
