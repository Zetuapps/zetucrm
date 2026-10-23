import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_chip.dart';
import '../../data/models/expense.dart';
import '../providers/finance_providers.dart';

class ExpenseDetailSheet extends ConsumerStatefulWidget {
  final Expense expense;
  final bool canApprove;

  const ExpenseDetailSheet({
    super.key,
    required this.expense,
    this.canApprove = false,
  });

  static Future<void> show(BuildContext context, Expense expense, {bool canApprove = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseDetailSheet(expense: expense, canApprove: canApprove),
    );
  }

  @override
  ConsumerState<ExpenseDetailSheet> createState() => _ExpenseDetailSheetState();
}

class _ExpenseDetailSheetState extends ConsumerState<ExpenseDetailSheet> {
  bool _isLoading = false;

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

  Future<void> _approveExpense() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.approveExpense(widget.expense.id);
      ref.read(expensesProvider.notifier).refresh();
      ref.read(chartOfAccountsProvider.notifier).refresh();
      ref.read(journalEntriesProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense approved and posted to General Ledger!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception:', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectExpense() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.rejectExpense(widget.expense.id);
      ref.read(expensesProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense marked as rejected.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception:', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this pending expense?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.deleteExpense(widget.expense.id);
      ref.read(expensesProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception:', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exp = widget.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(exp.status);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161C24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exp.description,
                  style: AppTypography.h3(
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppChip(
                    label: exp.status.toUpperCase(),
                    color: statusColor.withValues(alpha: 0.15),
                    textColor: statusColor,
                  ),
                  if (exp.isPending) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete Expense',
                      onPressed: _isLoading ? null : _deleteExpense,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: [
                // Amount Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expense Amount',
                            style: AppTypography.caption(color: AppColors.grey500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exp.currency} ${NumberFormat('#,##0.00').format(exp.amount)}',
                            style: AppTypography.h2(
                              color: isDark ? Colors.white : AppColors.grey900,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (exp.originalAmount != null && exp.originalAmount != exp.amount)
                            Text(
                              'Original: ${exp.currency} ${NumberFormat('#,##0.00').format(exp.originalAmount)} @ ${exp.exchangeRate}',
                              style: AppTypography.caption(color: AppColors.grey500),
                            ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.error.withOpacity(0.12),
                        child: const Icon(LucideIcons.receipt, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details Card
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow('Expense Date', exp.expenseDate, isDark),
                      _buildInfoRow('Payment Method', exp.paymentMethod.replaceAll('_', ' ').toUpperCase(), isDark),
                      if (exp.categoryName != null)
                        _buildInfoRow('Category', exp.categoryName!, isDark),
                      if (exp.expenseAccountName != null)
                        _buildInfoRow('Expense Account', exp.expenseAccountName!, isDark),
                      if (exp.paymentAccountName != null)
                        _buildInfoRow('Paid From Account', exp.paymentAccountName!, isDark),
                      if (exp.creatorName != null)
                        _buildInfoRow('Recorded By', exp.creatorName!, isDark),
                      if (exp.approverName != null)
                        _buildInfoRow('Approved By', exp.approverName!, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          if (exp.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reject',
                    variant: AppButtonVariant.danger,
                    isLoading: _isLoading,
                    icon: LucideIcons.xCircle,
                    onPressed: _rejectExpense,
                  ),
                ),
                if (widget.canApprove) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Approve & Post',
                      isLoading: _isLoading,
                      icon: LucideIcons.checkCircle,
                      onPressed: _approveExpense,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption(color: AppColors.grey500)),
          Text(
            value,
            style: AppTypography.subtitle2(
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
        ],
      ),
    );
  }
}
