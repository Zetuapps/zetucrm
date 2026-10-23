import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import 'tabs/expenses_tab.dart';
import 'tabs/requisitions_tab.dart';
import 'tabs/general_ledger_tab.dart';
import 'tabs/chart_of_accounts_tab.dart';
import 'tabs/financial_reports_tab.dart';
import 'sheets/expense_form_sheet.dart';
import 'sheets/requisition_form_sheet.dart';
import 'sheets/journal_entry_form_sheet.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const FinanceScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openQuickActionMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Financial Actions',
                style: AppTypography.subtitle1(
                  color: isDark ? Colors.white : AppColors.grey900,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.error.withOpacity(0.12),
                  child: const Icon(LucideIcons.receipt, color: AppColors.error, size: 20),
                ),
                title: const Text('Record Operating Expense'),
                subtitle: const Text('Vendor invoice, receipt, or operating payment'),
                onTap: () {
                  Navigator.pop(ctx);
                  ExpenseFormSheet.show(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: const Icon(LucideIcons.filePlus, color: AppColors.primary, size: 20),
                ),
                title: const Text('Submit Expense Requisition'),
                subtitle: const Text('Request manager approval & funds disbursement'),
                onTap: () {
                  Navigator.pop(ctx);
                  RequisitionFormSheet.show(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info.withOpacity(0.12),
                  child: const Icon(LucideIcons.bookOpen, color: AppColors.info, size: 20),
                ),
                title: const Text('New Double-Entry Journal Entry'),
                subtitle: const Text('Post manual debit & credit transactions to Ledger'),
                onTap: () {
                  Navigator.pop(ctx);
                  JournalEntryFormSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finance & Accounting',
          style: AppTypography.h3(
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary),
            tooltip: 'Financial Actions',
            onPressed: _openQuickActionMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white60 : AppColors.grey600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(LucideIcons.receipt, size: 18),
              text: 'Expenses',
            ),
            Tab(
              icon: Icon(LucideIcons.fileCheck, size: 18),
              text: 'Requisitions',
            ),
            Tab(
              icon: Icon(LucideIcons.bookOpen, size: 18),
              text: 'General Ledger',
            ),
            Tab(
              icon: Icon(LucideIcons.landmark, size: 18),
              text: 'Accounts',
            ),
            Tab(
              icon: Icon(LucideIcons.pieChart, size: 18),
              text: 'Reports',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpensesTab(),
          RequisitionsTab(),
          GeneralLedgerTab(),
          ChartOfAccountsTab(),
          FinancialReportsTab(),
        ],
      ),
    );
  }
}
