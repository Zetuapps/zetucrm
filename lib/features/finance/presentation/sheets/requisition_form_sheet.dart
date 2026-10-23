import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/unified_form.dart';
import '../../../../core/auth/auth_provider.dart';
import '../providers/finance_providers.dart';

class RequisitionFormSheet extends ConsumerStatefulWidget {
  const RequisitionFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RequisitionFormSheet(),
    );
  }

  @override
  ConsumerState<RequisitionFormSheet> createState() => _RequisitionFormSheetState();
}

class _RequisitionFormSheetState extends ConsumerState<RequisitionFormSheet> {
  final _titleController = TextEditingController();
  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _recipientAccountController = TextEditingController();
  final _recipientBankController = TextEditingController();

  String _currency = 'TZS';
  String _paymentMethod = 'mpesa';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final company = ref.read(authProvider).activeCompany;
    if (company != null && company.currency.isNotEmpty) {
      _currency = company.currency;
    }
  }

  final List<String> _paymentMethods = [
    'mpesa',
    'bank_transfer',
    'cash',
    'cheque',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _purposeController.dispose();
    _amountController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _recipientAccountController.dispose();
    _recipientBankController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a requisition title')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      final activeCompany = ref.read(authProvider).activeCompany;
      final exchangeRate = activeCompany?.exchangeRateUsdTzs ?? 2600.0;
      final payload = <String, dynamic>{
        'title': _titleController.text.trim(),
        'purpose': _purposeController.text.trim(),
        'amount': amount,
        'currency': _currency,
        'exchange_rate': exchangeRate,
        'payment_method': _paymentMethod,
        if (_recipientNameController.text.trim().isNotEmpty)
          'recipient_name': _recipientNameController.text.trim(),
        if (_recipientPhoneController.text.trim().isNotEmpty)
          'recipient_phone': _recipientPhoneController.text.trim(),
        if (_recipientAccountController.text.trim().isNotEmpty)
          'recipient_account_number': _recipientAccountController.text.trim(),
        if (_recipientBankController.text.trim().isNotEmpty)
          'recipient_bank_name': _recipientBankController.text.trim(),
      };

      await repo.createRequisition(payload);
      ref.read(requisitionsProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requisition submitted for approval successfully!'),
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

    return UnifiedFormSheet(
      title: 'Submit Expense Requisition',
      subtitle: 'Request disbursement approval from Department & Finance managers',
      submitLabel: 'Submit for Approval',
      isLoading: _isLoading,
      onSubmit: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          AppTextField(
            label: 'Requisition Title *',
            hint: 'e.g., Client Visit Transport, Emergency Server Hosting...',
            controller: _titleController,
            prefixIcon: const Icon(LucideIcons.fileText, size: 18),
          ),
          const SizedBox(height: 16),

          // Amount & Currency Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  label: 'Requested Amount *',
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



          // Payment Method Selector
          Text(
            'Disbursement Method',
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
                      m == 'mpesa'
                          ? 'M-PESA / MOBILE MONEY'
                          : m.replaceAll('_', ' ').toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recipient Details Section
          Text(
            'RECIPIENT PAYEE DETAILS',
            style: AppTypography.overline(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),

          AppTextField(
            label: 'Payee / Recipient Name',
            hint: 'e.g., John Doe / Vendor XYZ',
            controller: _recipientNameController,
            prefixIcon: const Icon(LucideIcons.user, size: 18),
          ),
          const SizedBox(height: 12),

          if (_paymentMethod == 'mpesa')
            AppTextField(
              label: 'M-Pesa / Mobile Phone Number',
              hint: 'e.g., 0712345678',
              controller: _recipientPhoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(LucideIcons.phone, size: 18),
            ),

          if (_paymentMethod == 'bank_transfer') ...[
            AppTextField(
              label: 'Bank Name',
              hint: 'e.g., CRDB Bank, NMB Bank, Stanbic...',
              controller: _recipientBankController,
              prefixIcon: const Icon(LucideIcons.landmark, size: 18),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Account Number',
              hint: 'e.g., 015023456789',
              controller: _recipientAccountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(LucideIcons.creditCard, size: 18),
            ),
          ],

          const SizedBox(height: 16),

          // Purpose / Reason
          AppTextField(
            label: 'Justification / Details',
            hint: 'Provide context for why this disbursement is needed...',
            controller: _purposeController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
