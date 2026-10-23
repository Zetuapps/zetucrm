import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../../../../shared/components/empty_state.dart';
import '../../../../core/auth/auth_provider.dart';
import '../providers/finance_providers.dart';
import '../sheets/requisition_form_sheet.dart';
import '../sheets/requisition_detail_sheet.dart';

class RequisitionsTab extends ConsumerStatefulWidget {
  const RequisitionsTab({super.key});

  @override
  ConsumerState<RequisitionsTab> createState() => _RequisitionsTabState();
}

class _RequisitionsTabState extends ConsumerState<RequisitionsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disbursed':
        return AppColors.info;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyCurrency = ref.watch(authProvider).activeCompany?.currency ?? 'TZS';
    final requisitionsAsync = ref.watch(requisitionsProvider);
    final filter = ref.watch(requisitionFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.filePlus, color: Colors.white),
        label: const Text('New Requisition', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => RequisitionFormSheet.show(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(requisitionsProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Search Bar
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.grey300,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search requisitions by #, title, payee...',
                  hintStyle: AppTypography.caption(color: AppColors.grey500),
                  prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.grey500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(requisitionFilterProvider.notifier).setSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (val) {
                  ref.read(requisitionFilterProvider.notifier).setSearch(val.trim());
                },
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // My Requests Toggle
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        filter.myRequests ? LucideIcons.check : LucideIcons.user,
                        size: 14,
                        color: filter.myRequests ? AppColors.primaryDark : AppColors.grey600,
                      ),
                      label: const Text('My Requests'),
                      selected: filter.myRequests,
                      selectedColor: AppColors.primaryLighter,
                      checkmarkColor: AppColors.primaryDark,
                      onSelected: (val) {
                        ref.read(requisitionFilterProvider.notifier).setMyRequests(val);
                      },
                    ),
                  ),
                  ...['all', 'pending_approval', 'approved', 'disbursed', 'rejected'].map((s) {
                    final isSelected = filter.status == s;
                    final label = s == 'all'
                        ? 'All Statuses'
                        : (s == 'pending_approval' ? 'Pending' : s.toUpperCase());

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLighter,
                        checkmarkColor: AppColors.primaryDark,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primaryDark
                              : (isDark ? Colors.white70 : AppColors.grey700),
                        ),
                        onSelected: (_) {
                          ref.read(requisitionFilterProvider.notifier).setStatus(s);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Async Requisitions Body
            requisitionsAsync.when(
              loading: () => AppShimmer.cardListShimmer(isDark: isDark, padding: EdgeInsets.zero),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Error loading requisitions: $err'),
              ),
              data: (data) {
                final requisitions = data.requisitions;
                final stats = data.stats;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.grey200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.clock, size: 14, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    Text('Pending (${stats.pendingCount})', style: AppTypography.caption(color: AppColors.grey500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  NumberFormat.compactCurrency(symbol: '$companyCurrency ').format(stats.pendingAmount),
                                  style: AppTypography.subtitle1(
                                    color: isDark ? Colors.white : AppColors.grey900,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.grey200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.checkCheck, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text('Approved (${stats.approvedCount})', style: AppTypography.caption(color: AppColors.grey500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  NumberFormat.compactCurrency(symbol: '$companyCurrency ').format(stats.approvedAmount),
                                  style: AppTypography.subtitle1(
                                    color: isDark ? Colors.white : AppColors.grey900,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.grey200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.send, size: 14, color: AppColors.info),
                                    const SizedBox(width: 4),
                                    Text('Disbursed (${stats.disbursedCount})', style: AppTypography.caption(color: AppColors.grey500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  NumberFormat.compactCurrency(symbol: '$companyCurrency ').format(stats.disbursedAmount),
                                  style: AppTypography.subtitle1(
                                    color: isDark ? Colors.white : AppColors.grey900,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (requisitions.isEmpty)
                      EmptyState(
                        icon: LucideIcons.fileCheck,
                        title: 'No Requisitions Found',
                        description: 'Submit expense requisitions to seek approvals and track disbursements.',
                        actionLabel: '+ New Requisition',
                        onAction: () => RequisitionFormSheet.show(context),
                      )
                    else
                      ...requisitions.map((req) {
                        final statusColor = _getStatusColor(req.status);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => RequisitionDetailSheet.show(context, req),
                            child: AppCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        req.requisitionNumber,
                                        style: AppTypography.caption(color: AppColors.primary).copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${req.currency} ${NumberFormat('#,##0.00').format(req.originalAmount ?? req.amount)}',
                                            style: AppTypography.subtitle1(
                                              color: isDark ? Colors.white : AppColors.grey900,
                                            ).copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          if (req.currency != companyCurrency && req.originalAmount != null)
                                            Text(
                                              'Base: $companyCurrency ${NumberFormat('#,##0.00').format(req.amount)}',
                                              style: AppTypography.caption(color: AppColors.grey500),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  Text(
                                    req.title,
                                    style: AppTypography.subtitle1(
                                      color: isDark ? Colors.white : AppColors.grey900,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),

                                  // Requester & Date
                                  Row(
                                    children: [
                                      if (req.requesterName != null) ...[
                                        Icon(LucideIcons.user, size: 13, color: AppColors.grey500),
                                        const SizedBox(width: 4),
                                        Text(req.requesterName!, style: AppTypography.caption(color: AppColors.grey500)),
                                        const SizedBox(width: 12),
                                      ],
                                      if (req.createdAt != null) ...[
                                        Icon(LucideIcons.calendar, size: 13, color: AppColors.grey500),
                                        const SizedBox(width: 4),
                                        Text(req.createdAt!, style: AppTypography.caption(color: AppColors.grey500)),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Status & Quick Action Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          AppChip(
                                            label: req.status.replaceAll('_', ' ').toUpperCase(),
                                            color: statusColor.withOpacity(0.12),
                                            textColor: statusColor,
                                          ),
                                          if (req.recipientName != null && req.recipientName!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            AppChip(
                                              label: req.recipientName!,
                                              color: isDark ? Colors.white10 : AppColors.grey200,
                                              textColor: isDark ? Colors.white70 : AppColors.grey700,
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (req.canApprove)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.successLighter,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(LucideIcons.checkCircle, size: 12, color: AppColors.success),
                                              SizedBox(width: 4),
                                              Text(
                                                'Action Required',
                                                style: TextStyle(
                                                  color: AppColors.success,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (req.canDisburse)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.infoLighter,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(LucideIcons.send, size: 12, color: AppColors.info),
                                              SizedBox(width: 4),
                                              Text(
                                                'Ready to Disburse',
                                                style: TextStyle(
                                                  color: AppColors.info,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
