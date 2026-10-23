import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../providers/finance_providers.dart';

class FinancialReportsTab extends ConsumerWidget {
  const FinancialReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pnlAsync = ref.watch(profitAndLossProvider);
    final tbAsync = ref.watch(trialBalanceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profitAndLossProvider);
          ref.invalidate(trialBalanceProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Profit and Loss Card
            Text(
              'PROFIT & LOSS (INCOME STATEMENT)',
              style: AppTypography.overline(
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),

            pnlAsync.when(
              loading: () => AppShimmer.cardListShimmer(isDark: isDark, count: 2, padding: EdgeInsets.zero),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.errorLighter, borderRadius: BorderRadius.circular(12)),
                child: Text('Error loading Profit & Loss: $err'),
              ),
              data: (pnl) {
                final isNetPositive = pnl.netIncome >= 0;

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Profit / Margin',
                                style: AppTypography.caption(color: AppColors.grey500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TZS ${NumberFormat('#,##0.00').format(pnl.netIncome)}',
                                style: AppTypography.h2(
                                  color: isNetPositive ? AppColors.success : AppColors.error,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: (isNetPositive ? AppColors.success : AppColors.error).withOpacity(0.12),
                            child: Icon(
                              isNetPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                              color: isNetPositive ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Revenue vs Expense Comparison
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Revenue', style: TextStyle(fontSize: 11, color: AppColors.success)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TZS ${NumberFormat.compact().format(pnl.totalRevenue)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Expenses', style: TextStyle(fontSize: 11, color: AppColors.error)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TZS ${NumberFormat.compact().format(pnl.totalExpenses)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (pnl.revenueItems.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text('Top Revenue Streams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        ...pnl.revenueItems.take(4).map((r) => _buildRowItem(r.accountName, r.amount, AppColors.success, isDark)),
                      ],

                      if (pnl.expenseItems.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text('Top Operating Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        ...pnl.expenseItems.take(4).map((e) => _buildRowItem(e.accountName, e.amount, AppColors.error, isDark)),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Trial Balance Card
            Text(
              'TRIAL BALANCE VERIFICATION',
              style: AppTypography.overline(
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),

            tbAsync.when(
              loading: () => AppShimmer.cardListShimmer(isDark: isDark, count: 2, padding: EdgeInsets.zero),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.errorLighter, borderRadius: BorderRadius.circular(12)),
                child: Text('Error loading Trial Balance: $err'),
              ),
              data: (tb) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Trial Balance State', style: AppTypography.caption(color: AppColors.grey500)),
                              const SizedBox(height: 4),
                              Text(
                                tb.isBalanced ? 'Balanced & Reconciled' : 'Unbalanced Discrepancy',
                                style: AppTypography.subtitle1(
                                  color: tb.isBalanced ? AppColors.success : AppColors.error,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          AppChip(
                            label: tb.isBalanced ? 'BALANCED' : 'CHECK LEDGER',
                            color: (tb.isBalanced ? AppColors.success : AppColors.error).withOpacity(0.12),
                            textColor: tb.isBalanced ? AppColors.success : AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Debits:', style: AppTypography.body2(color: isDark ? Colors.white70 : AppColors.grey800)),
                          Text(
                            'TZS ${NumberFormat('#,##0.00').format(tb.totalDebits)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Credits:', style: AppTypography.body2(color: isDark ? Colors.white70 : AppColors.grey800)),
                          Text(
                            'TZS ${NumberFormat('#,##0.00').format(tb.totalCredits)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.info),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String name, double amount, Color amountColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTypography.caption(color: isDark ? Colors.white70 : AppColors.grey800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'TZS ${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: amountColor),
          ),
        ],
      ),
    );
  }
}
