import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../../../../shared/components/unified_form.dart';
import '../../../../shared/components/app_text_field.dart';
import '../providers/finance_providers.dart';

class ChartOfAccountsTab extends ConsumerStatefulWidget {
  const ChartOfAccountsTab({super.key});

  @override
  ConsumerState<ChartOfAccountsTab> createState() => _ChartOfAccountsTabState();
}

class _ChartOfAccountsTabState extends ConsumerState<ChartOfAccountsTab> {
  final _searchController = TextEditingController();
  String _selectedType = 'all';

  final List<String> _accountTypes = [
    'all',
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'asset':
        return AppColors.primary;
      case 'liability':
        return AppColors.warning;
      case 'equity':
        return const Color(0xFF8B5CF6);
      case 'revenue':
        return AppColors.success;
      case 'expense':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  void _openAddAccountSheet() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.00');
    String type = 'expense';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => UnifiedFormSheet(
          title: 'Add Chart of Account',
          subtitle: 'Create a new ledger account for financial tracking',
          submitLabel: 'Create Account',
          isLoading: isLoading,
          onSubmit: () async {
            if (codeController.text.trim().isEmpty || nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter Account Code and Name')),
              );
              return;
            }

            setSheetState(() => isLoading = true);
            try {
              final repo = ref.read(financeRepositoryProvider);
              await repo.createChartOfAccount({
                'account_code': codeController.text.trim(),
                'name': nameController.text.trim(),
                'type': type,
                'opening_balance': double.tryParse(balanceController.text.trim()) ?? 0.0,
              });
              ref.read(chartOfAccountsProvider.notifier).refresh();

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chart of Account created successfully!'),
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
              if (mounted) setSheetState(() => isLoading = false);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Account Code *',
                hint: 'e.g., 6150, 1140, 5210...',
                controller: codeController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.hash, size: 18),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Account Name *',
                hint: 'e.g., Marketing Expenses, Office Petty Cash...',
                controller: nameController,
                prefixIcon: const Icon(LucideIcons.tag, size: 18),
              ),
              const SizedBox(height: 12),
              const Text('Account Type *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'asset', child: Text('Asset (Cash, Bank, Equipment)')),
                  DropdownMenuItem(value: 'liability', child: Text('Liability (Loans, Payables)')),
                  DropdownMenuItem(value: 'equity', child: Text('Equity (Owner Capital, Retained Earnings)')),
                  DropdownMenuItem(value: 'revenue', child: Text('Revenue (Sales, Service Fees)')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense (Operating, Cost of Sales)')),
                ],
                onChanged: (val) {
                  if (val != null) setSheetState(() => type = val);
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Opening Balance (Optional)',
                hint: '0.00',
                controller: balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(LucideIcons.banknote, size: 18),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsAsync = ref.watch(chartOfAccountsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Add Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _openAddAccountSheet,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(chartOfAccountsProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Search Box
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
                  hintText: 'Search account by code or name...',
                  hintStyle: AppTypography.caption(color: AppColors.grey500),
                  prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.grey500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),

            // Type Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _accountTypes.map((t) {
                  final isSelected = _selectedType == t;
                  final label = t == 'all' ? 'All Accounts' : t.toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLighter,
                      checkmarkColor: AppColors.primaryDark,
                      onSelected: (_) => setState(() => _selectedType = t),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Accounts List
            accountsAsync.when(
              loading: () => AppShimmer.cardListShimmer(isDark: isDark, padding: EdgeInsets.zero),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.errorLighter, borderRadius: BorderRadius.circular(12)),
                child: Text('Error loading chart of accounts: $err'),
              ),
              data: (accounts) {
                final query = _searchController.text.trim().toLowerCase();
                final filtered = accounts.where((a) {
                  if (_selectedType != 'all' && a.type.toLowerCase() != _selectedType.toLowerCase()) {
                    return false;
                  }
                  if (query.isNotEmpty) {
                    final matchName = a.name.toLowerCase().contains(query);
                    final matchCode = a.accountCode.toLowerCase().contains(query);
                    return matchName || matchCode;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No matching accounts found.'),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...filtered.map((acc) {
                      final typeColor = _getTypeColor(acc.type);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    acc.accountCode,
                                    style: TextStyle(
                                      color: typeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      style: AppTypography.subtitle2(
                                        color: isDark ? Colors.white : AppColors.grey900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        AppChip(
                                          label: acc.type.toUpperCase(),
                                          color: typeColor.withOpacity(0.1),
                                          textColor: typeColor,
                                        ),
                                        if (acc.subType != null) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '• ${acc.subType}',
                                            style: AppTypography.caption(color: AppColors.grey500),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'TZS ${NumberFormat('#,##0.00').format(acc.currentBalance)}',
                                    style: AppTypography.subtitle2(
                                      color: isDark ? Colors.white : AppColors.grey900,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Balance',
                                    style: AppTypography.caption(color: AppColors.grey500),
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
