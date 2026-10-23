import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/unified_form.dart';
import '../providers/finance_providers.dart';

class _EntryLineItem {
  String? chartOfAccountId;
  String type; // 'debit' or 'credit'
  final TextEditingController amountController;
  final TextEditingController descriptionController;

  _EntryLineItem({
    required this.type,
    String initialAmount = '',
    String initialDesc = '',
  })  : amountController = TextEditingController(text: initialAmount),
        descriptionController = TextEditingController(text: initialDesc);

  double get amount => double.tryParse(amountController.text.trim()) ?? 0.0;

  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
  }
}

class JournalEntryFormSheet extends ConsumerStatefulWidget {
  const JournalEntryFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JournalEntryFormSheet(),
    );
  }

  @override
  ConsumerState<JournalEntryFormSheet> createState() => _JournalEntryFormSheetState();
}

class _JournalEntryFormSheetState extends ConsumerState<JournalEntryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _refController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _currency = 'TZS';
  bool _isLoading = false;

  final List<_EntryLineItem> _lines = [];

  @override
  void initState() {
    super.initState();
    // Default 2 lines: 1 debit, 1 credit
    _lines.add(_EntryLineItem(type: 'debit'));
    _lines.add(_EntryLineItem(type: 'credit'));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _refController.dispose();
    _descriptionController.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  double get _totalDebit => _lines
      .where((l) => l.type == 'debit')
      .fold(0.0, (sum, l) => sum + l.amount);

  double get _totalCredit => _lines
      .where((l) => l.type == 'credit')
      .fold(0.0, (sum, l) => sum + l.amount);

  bool get _isBalanced {
    final diff = (_totalDebit - _totalCredit).abs();
    return _totalDebit > 0 && diff < 0.01;
  }

  void _addLine(String type) {
    setState(() {
      _lines.add(_EntryLineItem(type: type));
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A double entry requires at least 2 lines.')),
      );
      return;
    }
    setState(() {
      final removed = _lines.removeAt(index);
      removed.dispose();
    });
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
    if (!_formKey.currentState!.validate()) return;

    for (final line in _lines) {
      if (line.chartOfAccountId == null || line.chartOfAccountId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account for all lines.')),
        );
        return;
      }
      if (line.amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All entry lines must have amounts greater than 0.')),
        );
        return;
      }
    }

    if (!_isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debits ($_totalDebit) and Credits ($_totalCredit) must be equal.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      final payload = <String, dynamic>{
        'entry_date': _dateController.text.trim(),
        'reference_number': _refController.text.trim().isNotEmpty
            ? _refController.text.trim()
            : null,
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Manual Journal Entry',
        'currency': _currency,
        'original_amount': _totalDebit,
        'exchange_rate': 1.0,
        'status': 'posted',
        'lines': _lines.map((l) {
          return {
            'chart_of_account_id': l.chartOfAccountId,
            'type': l.type,
            'amount': l.amount,
            if (l.descriptionController.text.trim().isNotEmpty)
              'description': l.descriptionController.text.trim(),
          };
        }).toList(),
      };

      await repo.createJournalEntry(payload);
      ref.read(journalEntriesProvider.notifier).refresh();
      ref.read(chartOfAccountsProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry posted to General Ledger!'),
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
    final accountsAsync = ref.watch(chartOfAccountsProvider);
    final allAccounts = accountsAsync.asData?.value ?? [];

    return UnifiedFormSheet(
      title: 'New Journal Entry',
      subtitle: 'Post a balanced double-entry transaction to General Ledger',
      submitLabel: 'Post Entry',
      isLoading: _isLoading,
      onSubmit: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Currency Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: AppTextField(
                        label: 'Entry Date',
                        hint: 'YYYY-MM-DD',
                        controller: _dateController,
                        prefixIcon: const Icon(LucideIcons.calendar, size: 18),
                      ),
                    ),
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
            const SizedBox(height: 12),

            // Reference & Description
            AppTextField(
              label: 'Reference Number (Optional)',
              hint: 'e.g., JV-0042, INV-9812...',
              controller: _refController,
              prefixIcon: const Icon(LucideIcons.hash, size: 18),
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'Memo / Description',
              hint: 'e.g., Adjusting accruals, Owner injection, Office rent...',
              controller: _descriptionController,
              prefixIcon: const Icon(LucideIcons.fileText, size: 18),
            ),
            const SizedBox(height: 20),

            // Double Entry Live Balance Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isBalanced
                    ? AppColors.successLighter.withValues(alpha: 0.4)
                    : AppColors.warningLighter.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isBalanced ? AppColors.success : AppColors.warning,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Total Debits', style: TextStyle(fontSize: 11, color: Color(0xFF475467))),
                      const SizedBox(height: 2),
                      Text(
                        '$_currency ${NumberFormat('#,##0.00').format(_totalDebit)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                  Column(
                    children: [
                      const Text('Total Credits', style: TextStyle(fontSize: 11, color: Color(0xFF475467))),
                      const SizedBox(height: 2),
                      Text(
                        '$_currency ${NumberFormat('#,##0.00').format(_totalCredit)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.info),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                  Column(
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 11, color: Color(0xFF475467))),
                      const SizedBox(height: 2),
                      Text(
                        _isBalanced ? 'BALANCED' : 'UNBALANCED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _isBalanced ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ledger Lines Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'JOURNAL ENTRY LINES',
                  style: AppTypography.overline(
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _addLine('debit'),
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('+ Debit Line', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: () => _addLine('credit'),
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('+ Credit Line', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dynamic Lines
            ..._lines.asMap().entries.map((entry) {
              final idx = entry.key;
              final line = entry.value;
              final isDebit = line.type == 'debit';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDebit
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.info.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDebit
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.info.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDebit ? 'DEBIT LINE' : 'CREDIT LINE',
                            style: TextStyle(
                              color: isDebit ? AppColors.primary : AppColors.info,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (_lines.length > 2)
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                            onPressed: () => _removeLine(idx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Account Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInput : AppColors.grey100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.grey300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: line.chartOfAccountId,
                          hint: const Text('Select Account', style: TextStyle(fontSize: 13)),
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                          items: allAccounts.map((a) {
                            return DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(
                                '${a.accountCode} - ${a.name} (${a.type.toUpperCase()})',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => line.chartOfAccountId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Amount input
                    TextFormField(
                      controller: line.amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isDebit ? 'Debit Amount *' : 'Credit Amount *',
                        hintText: '0.00',
                        prefixIcon: Icon(
                          isDebit ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                          size: 16,
                          color: isDebit ? AppColors.primary : AppColors.info,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
