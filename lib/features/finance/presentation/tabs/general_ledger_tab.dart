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
import '../../data/models/journal_entry.dart';
import '../providers/finance_providers.dart';
import '../sheets/journal_entry_form_sheet.dart';

class GeneralLedgerTab extends ConsumerStatefulWidget {
  const GeneralLedgerTab({super.key});

  @override
  ConsumerState<GeneralLedgerTab> createState() => _GeneralLedgerTabState();
}

class _GeneralLedgerTabState extends ConsumerState<GeneralLedgerTab> {
  int _selectedView = 0; // 0: Journal Entries, 1: Ledger Lines

  Future<void> _reverseEntry(JournalEntry entry) async {
    final reasonController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: const Text('Reverse Journal Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reverse entry ${entry.referenceNumber ?? entry.id.substring(0, 8)}? A compensating reversal entry will be posted.',
              style: AppTypography.body2(color: isDark ? Colors.white70 : AppColors.grey800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reversal Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Post Reversal', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(financeRepositoryProvider);
      await repo.reverseJournalEntry(entry.id, reason: reasonController.text.trim());
      ref.read(journalEntriesProvider.notifier).refresh();
      ref.read(chartOfAccountsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reversal entry successfully created and posted.'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entriesAsync = ref.watch(journalEntriesProvider);
    final ledgerLinesAsync = ref.watch(generalLedgerLinesProvider);
    final filter = ref.watch(journalEntryFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('New Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => JournalEntryFormSheet.show(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(journalEntriesProvider.notifier).refresh();
          ref.invalidate(generalLedgerLinesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Switch View Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.grey200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedView = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedView == 0
                              ? (isDark ? AppColors.darkCard : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedView == 0
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Journal Entries',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedView == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _selectedView == 0
                                  ? AppColors.primary
                                  : (isDark ? Colors.white60 : AppColors.grey600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedView = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedView == 1
                              ? (isDark ? AppColors.darkCard : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedView == 1
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'General Ledger View',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedView == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _selectedView == 1
                                  ? AppColors.primary
                                  : (isDark ? Colors.white60 : AppColors.grey600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Status filter if in Journal Entries view
            if (_selectedView == 0)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'posted', 'draft'].map((s) {
                    final isSelected = filter.status == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s == 'all' ? 'All Entries' : s.toUpperCase()),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLighter,
                        checkmarkColor: AppColors.primaryDark,
                        onSelected: (_) => ref.read(journalEntryFilterProvider.notifier).setStatus(s),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 12),

            // Main Body: View 0 (Entries) or View 1 (Ledger Lines)
            if (_selectedView == 0)
              entriesAsync.when(
                loading: () => AppShimmer.cardListShimmer(isDark: isDark, padding: EdgeInsets.zero),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Error loading journal entries: $err'),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.bookOpen,
                      title: 'No Journal Entries',
                      description: 'Double-entry journal records maintain the company balance sheet & ledger.',
                      actionLabel: '+ New Journal Entry',
                      onAction: () => JournalEntryFormSheet.show(context),
                    );
                  }

                  return Column(
                    children: [
                      ...entries.map((entry) {
                        final isPosted = entry.status == 'posted';
                        final isReversed = entry.status == 'reversed';
                        final statusColor = isPosted
                            ? AppColors.success
                            : (isReversed ? AppColors.error : AppColors.warning);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          entry.referenceNumber ?? 'JV-${entry.id.substring(0, 6)}',
                                          style: AppTypography.subtitle2(color: AppColors.primary).copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.entryDate,
                                          style: AppTypography.caption(color: AppColors.grey500),
                                        ),
                                      ],
                                    ),
                                    AppChip(
                                      label: entry.status.toUpperCase(),
                                      color: statusColor.withOpacity(0.12),
                                      textColor: statusColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                if (entry.description != null && entry.description!.isNotEmpty)
                                  Text(
                                    entry.description!,
                                    style: AppTypography.body2(
                                      color: isDark ? Colors.white : AppColors.grey900,
                                    ),
                                  ),
                                const Divider(height: 16),

                                // Lines preview
                                ...entry.lines.map((line) {
                                  final isDebit = line.type == 'debit';
                                  final accName = line.account?.displayName ?? 'Account (${line.chartOfAccountId.substring(0, 6)})';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: isDebit
                                                      ? AppColors.primary.withOpacity(0.2)
                                                      : AppColors.info.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    isDebit ? 'D' : 'C',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDebit ? AppColors.primary : AppColors.info,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  accName,
                                                  style: AppTypography.caption(
                                                    color: isDark ? Colors.white70 : AppColors.grey800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${entry.currency} ${NumberFormat('#,##0.00').format(line.amount)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDebit ? AppColors.primary : AppColors.info,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                if (isPosted) ...[
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _reverseEntry(entry),
                                      icon: const Icon(LucideIcons.undo2, size: 13, color: AppColors.error),
                                      label: const Text('Reverse Entry', style: TextStyle(fontSize: 11, color: AppColors.error)),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        minimumSize: Size.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 80),
                    ],
                  );
                },
              )
            else
              // View 1: General Ledger Lines (Running Balances)
              ledgerLinesAsync.when(
                loading: () => AppShimmer.cardListShimmer(isDark: isDark, padding: EdgeInsets.zero),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Error loading ledger: $err'),
                ),
                data: (lines) {
                  if (lines.isEmpty) {
                    return const EmptyState(
                      icon: LucideIcons.layers,
                      title: 'No Ledger Transactions',
                      description: 'Ledger transactions are automatically generated when expenses or journal entries are posted.',
                    );
                  }

                  return Column(
                    children: [
                      ...lines.map((l) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${l.accountCode} • ${l.accountName}',
                                      style: AppTypography.subtitle2(
                                        color: isDark ? Colors.white : AppColors.grey900,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      l.date,
                                      style: AppTypography.caption(color: AppColors.grey500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l.description,
                                  style: AppTypography.caption(color: isDark ? Colors.white70 : AppColors.grey700),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (l.debit > 0)
                                          Text(
                                            'Debit: ${NumberFormat('#,##0.00').format(l.debit)}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        if (l.debit > 0 && l.credit > 0) const SizedBox(width: 8),
                                        if (l.credit > 0)
                                          Text(
                                            'Credit: ${NumberFormat('#,##0.00').format(l.credit)}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      'Bal: ${NumberFormat('#,##0.00').format(l.runningBalance)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white70 : AppColors.grey800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
