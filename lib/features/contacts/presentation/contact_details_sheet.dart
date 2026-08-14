import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/sync/sync_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';

class ContactDetailsSheet extends ConsumerStatefulWidget {
  final ContactEntry contact;
  const ContactDetailsSheet({super.key, required this.contact});

  @override
  ConsumerState<ContactDetailsSheet> createState() => _ContactDetailsSheetState();
}

class _ContactDetailsSheetState extends ConsumerState<ContactDetailsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.contact;
    final fullName = '${c.firstName} ${c.middleName ?? ''} ${c.lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : (c.company ?? 'Unnamed Contact');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLighter,
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: AppTypography.h3(color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTypography.h3(color: isDark ? Colors.white : AppColors.grey900)),
                      if (c.company != null)
                        Text('${c.title ?? 'Contact'} @ ${c.company}', style: AppTypography.caption(color: AppColors.grey500)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Stream computed metrics (Won value, Pipeline value, Est LTV)
          StreamBuilder<List<DealEntry>>(
            stream: (db.select(db.dealsTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
            builder: (context, snapshot) {
              final deals = snapshot.data ?? [];
              final wonDeals = deals.where((d) => d.status == 'won').fold<double>(0, (sum, d) => sum + d.amount);
              final pipelineValue = deals.where((d) => d.status == 'open').fold<double>(0, (sum, d) => sum + d.amount);
              final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCanvas : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.grey300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol('Total Won', fmt.format(wonDeals), AppColors.success),
                    _metricCol('Pipeline', fmt.format(pipelineValue), AppColors.info),
                    _metricCol('Est. LTV', fmt.format(wonDeals), AppColors.primary),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Activities'),
              Tab(text: 'Tasks'),
              Tab(text: 'Deals'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Details
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.email_outlined, 'Email', c.email ?? '—'),
                      _infoRow(Icons.phone_outlined, 'Phone', c.phone ?? '—'),
                      _infoRow(Icons.phone_paused_outlined, 'Alt. Phone', c.alternatePhone ?? '—'),
                      _infoRow(Icons.badge_outlined, 'TIN', c.tin ?? '—'),
                      _infoRow(Icons.receipt_long_outlined, 'VRN', c.vrn ?? '—'),
                      _infoRow(Icons.notes_outlined, 'Notes', c.notes ?? '—'),
                    ],
                  ),
                ),

                // Tab 2: Activities Stream
                StreamBuilder<List<ActivityEntry>>(
                  stream: (db.select(db.activitiesTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
                  builder: (context, snapshot) {
                    final activities = snapshot.data ?? [];
                    if (activities.isEmpty) return const Center(child: Text('No activities logged'));
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: activities.length,
                      itemBuilder: (ctx, i) {
                        final act = activities[i];
                        return ListTile(
                          leading: const Icon(Icons.history_rounded, color: AppColors.primary),
                          title: Text(act.subject ?? act.type),
                          subtitle: Text(act.description ?? ''),
                          trailing: Text(act.completedAt != null ? DateFormat('MMM d').format(act.completedAt!) : ''),
                        );
                      },
                    );
                  },
                ),

                // Tab 3: Tasks Stream
                StreamBuilder<List<TaskEntry>>(
                  stream: (db.select(db.tasksTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
                  builder: (context, snapshot) {
                    final tasks = snapshot.data ?? [];
                    if (tasks.isEmpty) return const Center(child: Text('No tasks associated'));
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tasks.length,
                      itemBuilder: (ctx, i) {
                        final task = tasks[i];
                        return ListTile(
                          leading: Icon(
                            task.status == 'completed' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: task.status == 'completed' ? AppColors.success : AppColors.warning,
                          ),
                          title: Text(task.title),
                          subtitle: Text(task.dueDate != null ? 'Due ${DateFormat('MMM d').format(task.dueDate!)}' : ''),
                        );
                      },
                    );
                  },
                ),

                // Tab 4: Deals Stream
                StreamBuilder<List<DealEntry>>(
                  stream: (db.select(db.dealsTable)..where((tbl) => tbl.contactLocalId.equals(c.localId))).watch(),
                  builder: (context, snapshot) {
                    final deals = snapshot.data ?? [];
                    if (deals.isEmpty) return const Center(child: Text('No deals associated'));
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: deals.length,
                      itemBuilder: (ctx, i) {
                        final deal = deals[i];
                        return ListTile(
                          leading: const Icon(Icons.monetization_on_rounded, color: AppColors.success),
                          title: Text(deal.title),
                          subtitle: Text('Stage: ${deal.stageName}'),
                          trailing: Text('\$${deal.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption(color: AppColors.grey500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey500),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(child: Text(val, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
