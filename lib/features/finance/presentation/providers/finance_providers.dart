import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../data/finance_repository.dart';
import '../../data/models/chart_of_account.dart';
import '../../data/models/journal_entry.dart';
import '../../data/models/expense.dart';
import '../../data/models/requisition.dart';
import '../../data/models/financial_report.dart';

// Repository Provider
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceRepository(apiClient: apiClient);
});

// ==========================================
// CHART OF ACCOUNTS
// ==========================================
class ChartOfAccountsNotifier extends AsyncNotifier<List<ChartOfAccount>> {
  @override
  Future<List<ChartOfAccount>> build() async {
    final repo = ref.watch(financeRepositoryProvider);
    return repo.getChartOfAccounts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financeRepositoryProvider);
      return repo.getChartOfAccounts();
    });
  }
}

final chartOfAccountsProvider =
    AsyncNotifierProvider<ChartOfAccountsNotifier, List<ChartOfAccount>>(
  ChartOfAccountsNotifier.new,
);

final expenseAccountsProvider = Provider<List<ChartOfAccount>>((ref) {
  final asyncAccounts = ref.watch(chartOfAccountsProvider);
  return asyncAccounts.asData?.value.where((a) => a.type == 'expense').toList() ?? [];
});

final paymentAccountsProvider = Provider<List<ChartOfAccount>>((ref) {
  final asyncAccounts = ref.watch(chartOfAccountsProvider);
  return asyncAccounts.asData?.value.where((a) {
    if (a.type != 'asset') return false;
    final sub = (a.subType ?? '').toLowerCase();
    final name = a.name.toLowerCase();
    return sub.contains('cash') ||
        sub.contains('bank') ||
        sub.contains('mpesa') ||
        sub.contains('current_asset') ||
        name.contains('cash') ||
        name.contains('bank') ||
        name.contains('mpesa') ||
        ['1110', '1120', '1130'].contains(a.accountCode);
  }).toList() ?? [];
});

// ==========================================
// EXPENSE CATEGORIES
// ==========================================
final expenseCategoriesProvider = FutureProvider<List<ExpenseCategory>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getExpenseCategories();
});

// ==========================================
// EXPENSES & STATS
// ==========================================
class ExpenseFilterState {
  final String status;
  final String categoryId;
  final String paymentAccountId;
  final String search;

  const ExpenseFilterState({
    this.status = 'all',
    this.categoryId = 'all',
    this.paymentAccountId = 'all',
    this.search = '',
  });

  ExpenseFilterState copyWith({
    String? status,
    String? categoryId,
    String? paymentAccountId,
    String? search,
  }) {
    return ExpenseFilterState(
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
      search: search ?? this.search,
    );
  }
}

class ExpenseFilterNotifier extends Notifier<ExpenseFilterState> {
  @override
  ExpenseFilterState build() => const ExpenseFilterState();

  void setStatus(String status) => state = state.copyWith(status: status);
  void setCategory(String catId) => state = state.copyWith(categoryId: catId);
  void setPaymentAccount(String accId) => state = state.copyWith(paymentAccountId: accId);
  void setSearch(String search) => state = state.copyWith(search: search);
  void reset() => state = const ExpenseFilterState();
}

final expenseFilterProvider =
    NotifierProvider<ExpenseFilterNotifier, ExpenseFilterState>(
  ExpenseFilterNotifier.new,
);

typedef ExpensePayload = ({List<Expense> expenses, ExpenseStats stats, bool canApprove});

class ExpensesNotifier extends AsyncNotifier<ExpensePayload> {
  @override
  Future<ExpensePayload> build() async {
    final repo = ref.watch(financeRepositoryProvider);
    final filter = ref.watch(expenseFilterProvider);

    return repo.getExpenses(
      status: filter.status,
      categoryId: filter.categoryId,
      paymentAccountId: filter.paymentAccountId,
      search: filter.search,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financeRepositoryProvider);
      final filter = ref.read(expenseFilterProvider);
      return repo.getExpenses(
        status: filter.status,
        categoryId: filter.categoryId,
        paymentAccountId: filter.paymentAccountId,
        search: filter.search,
      );
    });
  }
}

final expensesProvider =
    AsyncNotifierProvider<ExpensesNotifier, ExpensePayload>(
  ExpensesNotifier.new,
);

// ==========================================
// REQUISITIONS & APPROVALS
// ==========================================
class RequisitionFilterState {
  final String status;
  final bool myRequests;
  final String search;

  const RequisitionFilterState({
    this.status = 'all',
    this.myRequests = false,
    this.search = '',
  });

  RequisitionFilterState copyWith({
    String? status,
    bool? myRequests,
    String? search,
  }) {
    return RequisitionFilterState(
      status: status ?? this.status,
      myRequests: myRequests ?? this.myRequests,
      search: search ?? this.search,
    );
  }
}

class RequisitionFilterNotifier extends Notifier<RequisitionFilterState> {
  @override
  RequisitionFilterState build() => const RequisitionFilterState();

  void setStatus(String status) => state = state.copyWith(status: status);
  void setMyRequests(bool value) => state = state.copyWith(myRequests: value);
  void setSearch(String search) => state = state.copyWith(search: search);
  void reset() => state = const RequisitionFilterState();
}

final requisitionFilterProvider =
    NotifierProvider<RequisitionFilterNotifier, RequisitionFilterState>(
  RequisitionFilterNotifier.new,
);

typedef RequisitionPayload = ({List<Requisition> requisitions, RequisitionStats stats});

class RequisitionsNotifier extends AsyncNotifier<RequisitionPayload> {
  @override
  Future<RequisitionPayload> build() async {
    final repo = ref.watch(financeRepositoryProvider);
    final filter = ref.watch(requisitionFilterProvider);

    return repo.getRequisitions(
      status: filter.status,
      myRequests: filter.myRequests,
      search: filter.search,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financeRepositoryProvider);
      final filter = ref.read(requisitionFilterProvider);
      return repo.getRequisitions(
        status: filter.status,
        myRequests: filter.myRequests,
        search: filter.search,
      );
    });
  }
}

final requisitionsProvider =
    AsyncNotifierProvider<RequisitionsNotifier, RequisitionPayload>(
  RequisitionsNotifier.new,
);

// ==========================================
// GENERAL LEDGER & JOURNAL ENTRIES
// ==========================================
class JournalEntryFilterState {
  final String status;
  final String? dateFrom;
  final String? dateTo;

  const JournalEntryFilterState({
    this.status = 'all',
    this.dateFrom,
    this.dateTo,
  });

  JournalEntryFilterState copyWith({
    String? status,
    String? dateFrom,
    String? dateTo,
  }) {
    return JournalEntryFilterState(
      status: status ?? this.status,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }
}

class JournalEntryFilterNotifier extends Notifier<JournalEntryFilterState> {
  @override
  JournalEntryFilterState build() => const JournalEntryFilterState();

  void setStatus(String status) => state = state.copyWith(status: status);
  void setDateRange(String? from, String? to) =>
      state = state.copyWith(dateFrom: from, dateTo: to);
  void reset() => state = const JournalEntryFilterState();
}

final journalEntryFilterProvider =
    NotifierProvider<JournalEntryFilterNotifier, JournalEntryFilterState>(
  JournalEntryFilterNotifier.new,
);

class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final repo = ref.watch(financeRepositoryProvider);
    final filter = ref.watch(journalEntryFilterProvider);

    return repo.getJournalEntries(
      status: filter.status,
      dateFrom: filter.dateFrom,
      dateTo: filter.dateTo,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financeRepositoryProvider);
      final filter = ref.read(journalEntryFilterProvider);
      return repo.getJournalEntries(
        status: filter.status,
        dateFrom: filter.dateFrom,
        dateTo: filter.dateTo,
      );
    });
  }
}

final journalEntriesProvider =
    AsyncNotifierProvider<JournalEntriesNotifier, List<JournalEntry>>(
  JournalEntriesNotifier.new,
);

// General Ledger Report Lines
final generalLedgerLinesProvider = FutureProvider<List<GeneralLedgerLine>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  final filter = ref.watch(journalEntryFilterProvider);
  return repo.getGeneralLedgerReport(
    dateFrom: filter.dateFrom,
    dateTo: filter.dateTo,
  );
});

// ==========================================
// FINANCIAL REPORTS
// ==========================================
final profitAndLossProvider = FutureProvider<ProfitAndLossReport>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getProfitAndLoss();
});

final trialBalanceProvider = FutureProvider<TrialBalanceReport>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getTrialBalance();
});
