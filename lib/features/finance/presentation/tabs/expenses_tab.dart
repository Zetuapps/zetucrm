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
import '../providers/finance_providers.dart';
import '../sheets/expense_form_sheet.dart';
import '../sheets/expense_detail_sheet.dart';

class ExpensesTab extends ConsumerStatefulWidget {
  const ExpensesTab({super.key});

  @override
  ConsumerState<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends ConsumerState<ExpensesTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'mpesa':
        return LucideIcons.smartphone;
      case 'bank_transfer':
        return LucideIcons.landmark;
      case 'credit_card':
        return LucideIcons.creditCard;
      default:
        return LucideIcons.banknote;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expensesAsync = ref.watch(expensesProvider);
    final filter = ref.watch(expenseFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Record Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => ExpenseFormSheet.show(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expensesProvider.notifier).refresh();
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
                  hintText: 'Search expenses by vendor, description, account...',
                  hintStyle: AppTypography.caption(color: AppColors.grey500),
                  prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.grey500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(expenseFilterProvider.notifier).setSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (val) {
                  ref.read(expenseFilterProvider.notifier).setSearch(val.trim());
                },
              ),
            ),
            const SizedBox(height: 12),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'pending', 'approved', 'rejected'].map((s) {
                  final isSelected = filter.status == s;
                  final label = s == 'all' ? 'All Status' : s.toUpperCase();
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
                        ref.read(expenseFilterProvider.notifier).setStatus(s);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Async Body
            expensesAsync.when(
              loading: () => AppShimmer.cardListShimmer(isDark: isDark, padding: EdgeInsets.zero),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Error loading expenses: $err'),
              ),
              data: (data) {
                final expenses = data.expenses;
                final stats = data.stats;
                final canApprove = data.canApprove;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Stats Cards
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
                                  NumberFormat.compactCurrency(symbol: 'TZS ').format(stats.pendingAmount),
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
                                    const Icon(LucideIcons.calendar, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text('This Month', style: AppTypography.caption(color: AppColors.grey500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  NumberFormat.compactCurrency(symbol: 'TZS ').format(stats.thisMonthAmount),
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
                                    const Icon(LucideIcons.checkCircle, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text('Total Approved', style: AppTypography.caption(color: AppColors.grey500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  NumberFormat.compactCurrency(symbol: 'TZS ').format(stats.totalAmount),
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

                    if (expenses.isEmpty)
                      EmptyState(
                        icon: LucideIcons.receipt,
                        title: 'No Expenses Found',
                        description: 'Record operating expenses, supplier payments, or miscellaneous costs.',
                        actionLabel: '+ Record Expense',
                        onAction: () => ExpenseFormSheet.show(context),
                      )
                    else
                      ...expenses.map((exp) {
                        final statusColor = _getStatusColor(exp.status);
                        final methodIcon = _getPaymentMethodIcon(exp.paymentMethod);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => ExpenseDetailSheet.show(context, exp, canApprove: canApprove),
                            child: AppCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exp.description,
                                          style: AppTypography.subtitle1(
                                            color: isDark ? Colors.white : AppColors.grey900,
                                          ).copyWith(fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${exp.currency} ${NumberFormat('#,##0.00').format(exp.amount)}',
                                        style: AppTypography.subtitle1(
                                          color: isDark ? Colors.white : AppColors.grey900,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Date and Payee Row
                                  Row(
                                    children: [
                                      Icon(LucideIcons.calendar, size: 13, color: AppColors.grey500),
                                      const SizedBox(width: 4),
                                      Text(exp.expenseDate, style: AppTypography.caption(color: AppColors.grey500)),
                                      const SizedBox(width: 12),
                                      Icon(methodIcon, size: 13, color: AppColors.grey500),
                                      const SizedBox(width: 4),
                                      Text(
                                        exp.paymentMethod.toUpperCase(),
                                        style: AppTypography.caption(color: AppColors.grey500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Accounts & Status Tags
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            if (exp.categoryName != null)
                                              AppChip(
                                                label: exp.categoryName!,
                                                color: isDark ? Colors.white10 : AppColors.grey200,
                                                textColor: isDark ? Colors.white70 : AppColors.grey700,
                                              ),
                                            if (exp.paymentAccountName != null)
                                              AppChip(
                                                label: exp.paymentAccountName!,
                                                color: AppColors.info.withOpacity(0.1),
                                                textColor: AppColors.info,
                                              ),
                                          ],
                                        ),
                                      ),
                                      AppChip(
                                        label: exp.status.toUpperCase(),
                                        color: statusColor.withOpacity(0.12),
                                        textColor: statusColor,
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
