import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_chip.dart';
import '../../data/models/requisition.dart';
import '../../../../core/auth/auth_provider.dart';
import '../providers/finance_providers.dart';

class RequisitionDetailSheet extends ConsumerStatefulWidget {
  final Requisition requisition;

  const RequisitionDetailSheet({super.key, required this.requisition});

  static Future<void> show(BuildContext context, Requisition requisition) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequisitionDetailSheet(requisition: requisition),
    );
  }

  @override
  ConsumerState<RequisitionDetailSheet> createState() => _RequisitionDetailSheetState();
}

class _RequisitionDetailSheetState extends ConsumerState<RequisitionDetailSheet> {
  bool _isActioning = false;

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

  Future<void> _approveRequisition() async {
    final commentsController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseAccounts = ref.read(expenseAccountsProvider);
    final activeCompany = ref.read(authProvider).activeCompany;
    final companyCurrency = activeCompany?.currency ?? 'TZS';

    String? selectedAccountId = widget.requisition.chartOfAccountId;
    if (selectedAccountId == null || !expenseAccounts.any((a) => a.id == selectedAccountId)) {
      if (expenseAccounts.isNotEmpty) {
        selectedAccountId = expenseAccounts.first.id;
      }
    }

    final displayAmount = widget.requisition.originalAmount ?? widget.requisition.amount;
    final isForeignCurrency = widget.requisition.currency != companyCurrency;
    String? selectedAccount = selectedAccountId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          title: const Text('Approve Requisition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm approval for ${widget.requisition.currency} ${NumberFormat('#,##0.00').format(displayAmount)}',
                  style: AppTypography.subtitle1(
                    color: isDark ? Colors.white : AppColors.grey900,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                if (isForeignCurrency) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Company Base: $companyCurrency ${NumberFormat('#,##0.00').format(widget.requisition.amount)}',
                    style: AppTypography.caption(color: AppColors.grey500),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Expense Account / Budget Category',
                  style: AppTypography.subtitle2(
                    color: isDark ? Colors.white70 : AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInput : AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedAccount,
                      hint: const Text('Select expense budget account'),
                      isExpanded: true,
                      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                      items: expenseAccounts.map((acc) {
                        return DropdownMenuItem<String>(
                          value: acc.id,
                          child: Text(
                            '${acc.accountCode} - ${acc.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedAccount = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Approval notes / comments (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isActioning = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.approveRequisition(
        widget.requisition.id,
        comments: commentsController.text.trim(),
        chartOfAccountId: selectedAccount,
      );
      ref.read(requisitionsProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requisition step successfully approved!'),
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
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Future<void> _rejectRequisition() async {
    final reasonController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: const Text('Reject Requisition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a mandatory reason for declining this request:',
              style: AppTypography.body2(color: isDark ? Colors.white70 : AppColors.grey800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Rejection *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || reasonController.text.trim().isEmpty) return;

    setState(() => _isActioning = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.rejectRequisition(
        widget.requisition.id,
        reason: reasonController.text.trim(),
      );
      ref.read(requisitionsProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requisition rejected.'),
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
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Future<void> _disburseRequisition() async {
    final paymentAccounts = ref.read(paymentAccountsProvider);
    if (paymentAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active disbursement accounts found')),
      );
      return;
    }

    String selectedAccountId = paymentAccounts.first.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          title: const Text('Disburse Funds & Post Ledger'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disbursing ${widget.requisition.currency} ${NumberFormat('#,##0.00').format(widget.requisition.originalAmount ?? widget.requisition.amount)}.\nSelect paying source asset account:',
                style: AppTypography.body2(color: isDark ? Colors.white70 : AppColors.grey800),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Disbursement Account (Cash/Bank)',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: paymentAccounts.map((acc) {
                  return DropdownMenuItem<String>(
                    value: acc.id,
                    child: Text('${acc.accountCode} - ${acc.name}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedAccountId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Release Funds', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isActioning = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.disburseRequisition(
        widget.requisition.id,
        disbursementAccountId: selectedAccountId,
        paymentMethod: widget.requisition.paymentMethod,
      );
      ref.read(requisitionsProvider.notifier).refresh();
      ref.read(chartOfAccountsProvider.notifier).refresh();
      ref.read(journalEntriesProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funds disbursed and double-entry posted to General Ledger!'),
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
      if (mounted) setState(() => _isActioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.requisition;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(req.status);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.requisitionNumber,
                      style: AppTypography.caption(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      req.title,
                      style: AppTypography.h3(
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                  ],
                ),
              ),
              AppChip(
                label: req.status.replaceAll('_', ' ').toUpperCase(),
                color: statusColor.withOpacity(0.15),
                textColor: statusColor,
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
                            'Total Amount Requested',
                            style: AppTypography.caption(color: AppColors.grey500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${req.currency} ${NumberFormat('#,##0.00').format(req.originalAmount ?? req.amount)}',
                            style: AppTypography.h2(
                              color: isDark ? Colors.white : AppColors.grey900,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (req.currency != (ref.watch(authProvider).activeCompany?.currency ?? 'TZS')) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Base Equivalent: ${ref.watch(authProvider).activeCompany?.currency ?? "TZS"} ${NumberFormat('#,##0.00').format(req.amount)}',
                              style: AppTypography.caption(color: AppColors.grey500),
                            ),
                          ],
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: const Icon(LucideIcons.banknote, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payee / Recipient Info Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISBURSEMENT & RECIPIENT INFO',
                        style: AppTypography.overline(
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Payment Method', req.paymentMethod.toUpperCase(), isDark),
                      if (req.recipientName != null && req.recipientName!.isNotEmpty)
                        _buildInfoRow('Recipient Name', req.recipientName!, isDark),
                      if (req.recipientPhone != null && req.recipientPhone!.isNotEmpty)
                        _buildInfoRow('Phone Number', req.recipientPhone!, isDark),
                      if (req.recipientAccountNumber != null && req.recipientAccountNumber!.isNotEmpty)
                        _buildInfoRow('Account Number', req.recipientAccountNumber!, isDark),
                      if (req.recipientBankName != null && req.recipientBankName!.isNotEmpty)
                        _buildInfoRow('Bank Name', req.recipientBankName!, isDark),
                      if (req.requesterName != null)
                        _buildInfoRow('Requested By', req.requesterName!, isDark),
                      if (req.createdAt != null)
                        _buildInfoRow('Date Submitted', req.createdAt!, isDark),
                      if (req.expenseAccountName != null)
                        _buildInfoRow('Budget Line', req.expenseAccountName!, isDark),
                      if (req.disbursementAccountName != null)
                        _buildInfoRow('Paid From', req.disbursementAccountName!, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Purpose
                if (req.purpose != null && req.purpose!.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JUSTIFICATION / DETAILS',
                          style: AppTypography.overline(
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          req.purpose!,
                          style: AppTypography.body2(
                            color: isDark ? Colors.white70 : AppColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Rejection Reason Alert
                if (req.rejectionReason != null && req.rejectionReason!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorLighter,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rejection Reason:',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                req.rejectionReason!,
                                style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Approval History Timeline
                if (req.approvals.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APPROVAL STEPS TIMELINE',
                          style: AppTypography.overline(
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                        const Divider(height: 20),
                        ...req.approvals.map((a) {
                          final isStepDone = a.status == 'approved';
                          final isStepReject = a.status == 'rejected';
                          final stepColor = isStepDone
                              ? AppColors.success
                              : (isStepReject ? AppColors.error : AppColors.warning);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: stepColor.withOpacity(0.15),
                                  child: Icon(
                                    isStepDone
                                        ? LucideIcons.check
                                        : (isStepReject ? LucideIcons.x : LucideIcons.clock),
                                    size: 14,
                                    color: stepColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tier ${a.stepOrder} Approval',
                                        style: AppTypography.subtitle2(
                                          color: isDark ? Colors.white : AppColors.grey900,
                                        ),
                                      ),
                                      if (a.approverName != null)
                                        Text(
                                          'Actioned by: ${a.approverName}',
                                          style: AppTypography.caption(color: AppColors.grey500),
                                        ),
                                      if (a.comments != null && a.comments!.isNotEmpty)
                                        Text(
                                          '"${a.comments}"',
                                          style: AppTypography.caption(
                                            color: isDark ? Colors.white60 : AppColors.grey700,
                                          ).copyWith(fontStyle: FontStyle.italic),
                                        ),
                                    ],
                                  ),
                                ),
                                AppChip(
                                  label: a.status.toUpperCase(),
                                  color: stepColor.withOpacity(0.12),
                                  textColor: stepColor,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // Bottom Action Buttons
          if (req.canApprove || req.canDisburse) ...[
            const SizedBox(height: 12),
            if (req.canApprove)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reject',
                      variant: AppButtonVariant.danger,
                      isLoading: _isActioning,
                      icon: LucideIcons.xCircle,
                      onPressed: _rejectRequisition,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Approve Step',
                      isLoading: _isActioning,
                      icon: LucideIcons.checkCircle,
                      onPressed: _approveRequisition,
                    ),
                  ),
                ],
              ),
            if (req.canDisburse)
              AppButton(
                label: 'Disburse Funds Now',
                isLoading: _isActioning,
                icon: LucideIcons.send,
                onPressed: _disburseRequisition,
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
