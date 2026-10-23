import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/unified_form.dart';
import '../../data/models/chart_of_account.dart';
import '../providers/finance_providers.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExpenseFormSheet(),
    );
  }

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  String _currency = 'TZS';
  String? _selectedCategoryId;
  String? _selectedExpenseAccountId;
  String? _selectedPaymentAccountId;
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'cash',
    'mpesa',
    'bank_transfer',
    'credit_card',
    'cheque',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense amount')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description or vendor name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      final payload = <String, dynamic>{
        'amount': amount,
        'currency': _currency,
        'description': _descriptionController.text.trim(),
        'expense_date': _dateController.text.trim(),
        'payment_method': _paymentMethod,
        if (_selectedCategoryId != null) 'expense_category_id': _selectedCategoryId,
        if (_selectedExpenseAccountId != null) 'chart_of_account_id': _selectedExpenseAccountId,
        if (_selectedPaymentAccountId != null) 'payment_account_id': _selectedPaymentAccountId,
      };

      await repo.createExpense(payload);
      ref.read(expensesProvider.notifier).refresh();
      ref.read(chartOfAccountsProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense submitted successfully and pending approval.'),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final expenseAccounts = ref.watch(expenseAccountsProvider);
    final paymentAccounts = ref.watch(paymentAccountsProvider);

    return UnifiedFormSheet(
      title: 'Record New Expense',
      subtitle: 'Post an operational expense or vendor payment',
      submitLabel: 'Submit Expense',
      isLoading: _isLoading,
      onSubmit: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount & Currency Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  label: 'Amount *',
                  hint: '0.00',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(LucideIcons.banknote, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency',
                      style: AppTypography.subtitle2(
                        color: isDark ? Colors.white70 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
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
                          value: _currency,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                          items: const [
                            DropdownMenuItem(value: 'TZS', child: Text('TZS')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _currency = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expense Account (Debit - Category Account)
          Text(
            'Expense Account (Chart of Accounts)',
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
                value: _selectedExpenseAccountId,
                hint: const Text('Select expense account'),
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
                onChanged: (val) => setState(() => _selectedExpenseAccountId = val),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Account (Credit - Cash/Bank/M-Pesa)
          Text(
            'Paid From (Cash / Bank / M-Pesa)',
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
                value: _selectedPaymentAccountId,
                hint: const Text('Select payment account'),
                isExpanded: true,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                items: paymentAccounts.map((acc) {
                  return DropdownMenuItem<String>(
                    value: acc.id,
                    child: Text(
                      '${acc.accountCode} - ${acc.name} (${NumberFormat.currency(symbol: '', decimalDigits: 0).format(acc.currentBalance)})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPaymentAccountId = val;
                    if (val != null) {
                      final found = paymentAccounts.firstWhere((a) => a.id == val, orElse: () => ChartOfAccount(id: '', accountCode: '', name: '', type: 'asset'));
                      final name = found.name.toLowerCase();
                      final sub = (found.subType ?? '').toLowerCase();
                      if (name.contains('mpesa') || sub.contains('mpesa')) {
                        _paymentMethod = 'mpesa';
                      } else if (name.contains('bank') || sub.contains('bank')) {
                        _paymentMethod = 'bank_transfer';
                      } else {
                        _paymentMethod = 'cash';
                      }
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Expense Category & Payment Method
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: AppTypography.subtitle2(
                        color: isDark ? Colors.white70 : AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    categoriesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                      data: (cats) => Container(
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
                            value: _selectedCategoryId,
                            hint: const Text('Category'),
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                            items: cats.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(c.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategoryId = val),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Method',
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
                          value: _paymentMethod,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                          items: _paymentMethods.map((m) {
                            return DropdownMenuItem<String>(
                              value: m,
                              child: Text(
                                m.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _paymentMethod = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Picker Field
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: AppTextField(
                label: 'Expense Date',
                hint: 'YYYY-MM-DD',
                controller: _dateController,
                prefixIcon: const Icon(LucideIcons.calendar, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description Field
          AppTextField(
            label: 'Description / Purpose *',
            hint: 'e.g., Office Supplies, Fuel for delivery van...',
            controller: _descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
