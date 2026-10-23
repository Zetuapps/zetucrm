import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/chart_of_account.dart';
import 'models/journal_entry.dart';
import 'models/expense.dart';
import 'models/requisition.dart';
import 'models/financial_report.dart';

class FinanceRepository {
  final ApiClient apiClient;

  FinanceRepository({required this.apiClient});

  Dio get _dio => apiClient.dio;

  // ==========================================
  // CHART OF ACCOUNTS
  // ==========================================
  Future<List<ChartOfAccount>> getChartOfAccounts() async {
    final response = await _dio.get('/chart-of-accounts');
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as List? ?? [];
      return data.map((json) => ChartOfAccount.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ChartOfAccount> createChartOfAccount(Map<String, dynamic> data) async {
    final response = await _dio.post('/chart-of-accounts', data: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ChartOfAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to create account');
  }

  // ==========================================
  // GENERAL LEDGER & JOURNAL ENTRIES
  // ==========================================
  Future<List<JournalEntry>> getJournalEntries({
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': 30};
    if (status != null && status != 'all') query['status'] = status;
    if (dateFrom != null) query['date_from'] = dateFrom;
    if (dateTo != null) query['date_to'] = dateTo;

    final response = await _dio.get('/journal-entries', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      final rawData = response.data['data'];
      List items = [];
      if (rawData is Map && rawData['data'] is List) {
        items = rawData['data'] as List;
      } else if (rawData is List) {
        items = rawData;
      }
      return items.map((json) => JournalEntry.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<JournalEntry> createJournalEntry(Map<String, dynamic> data) async {
    final response = await _dio.post('/journal-entries', data: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return JournalEntry.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to create journal entry');
  }

  Future<JournalEntry> reverseJournalEntry(String id, {String? reason}) async {
    final response = await _dio.post(
      '/journal-entries/$id/reverse',
      data: {'reason': reason ?? 'Reversal requested from mobile app'},
    );
    if (response.statusCode == 200) {
      return JournalEntry.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to reverse journal entry');
  }

  Future<List<GeneralLedgerLine>> getGeneralLedgerReport({
    String? accountId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final query = <String, dynamic>{};
    if (accountId != null) query['account_id'] = accountId;
    if (dateFrom != null) query['date_from'] = dateFrom;
    if (dateTo != null) query['date_to'] = dateTo;

    final response = await _dio.get('/reports/general-ledger', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'];
      List<GeneralLedgerLine> lines = [];
      if (data is List) {
        for (final accGroup in data) {
          if (accGroup is Map && accGroup['items'] is List) {
            final accName = accGroup['name']?.toString() ?? '';
            final accCode = accGroup['account_code']?.toString() ?? '';
            final accType = accGroup['type']?.toString() ?? '';
            for (final item in accGroup['items']) {
              final map = Map<String, dynamic>.from(item as Map);
              map['account_name'] = accName;
              map['account_code'] = accCode;
              map['account_type'] = accType;
              lines.add(GeneralLedgerLine.fromJson(map));
            }
          }
        }
      }
      return lines;
    }
    return [];
  }

  // ==========================================
  // EXPENSES
  // ==========================================
  Future<({List<Expense> expenses, ExpenseStats stats, bool canApprove})> getExpenses({
    String? status,
    String? categoryId,
    String? paymentAccountId,
    String? search,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': 30};
    if (status != null && status != 'all') query['status'] = status;
    if (categoryId != null && categoryId != 'all') query['category_id'] = categoryId;
    if (paymentAccountId != null && paymentAccountId != 'all') query['payment_account_id'] = paymentAccountId;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _dio.get('/expenses', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      final rawData = response.data['data'];
      List items = [];
      if (rawData is List) {
        items = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        items = rawData['data'] as List;
      }

      final expenses = items.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
      final stats = response.data['stats'] != null
          ? ExpenseStats.fromJson(response.data['stats'] as Map<String, dynamic>)
          : const ExpenseStats();
      final canApprove = response.data['can_approve'] == true;

      return (expenses: expenses, stats: stats, canApprove: canApprove);
    }
    return (expenses: <Expense>[], stats: const ExpenseStats(), canApprove: false);
  }

  Future<Expense> createExpense(Map<String, dynamic> data) async {
    final response = await _dio.post('/expenses', data: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Expense.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to record expense');
  }

  Future<Expense> updateExpense(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/expenses/$id', data: data);
    if (response.statusCode == 200) {
      return Expense.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to update expense');
  }

  Future<void> deleteExpense(String id) async {
    final response = await _dio.delete('/expenses/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.data['message'] ?? 'Failed to delete expense');
    }
  }

  Future<Expense> approveExpense(String id, {String? paymentAccountId}) async {
    final payload = <String, dynamic>{};
    if (paymentAccountId != null) payload['payment_account_id'] = paymentAccountId;

    final response = await _dio.post('/expenses/$id/approve', data: payload);
    if (response.statusCode == 200) {
      return Expense.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to approve expense');
  }

  Future<Expense> rejectExpense(String id) async {
    final response = await _dio.post('/expenses/$id/reject');
    if (response.statusCode == 200) {
      return Expense.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to reject expense');
  }

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final response = await _dio.get('/expense-categories');
    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['data'] as List? ?? [];
      return list.map((json) => ExpenseCategory.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ExpenseCategory> createExpenseCategory(String name, {String? chartOfAccountId}) async {
    final response = await _dio.post('/expense-categories', data: {
      'name': name,
      if (chartOfAccountId != null) 'chart_of_account_id': chartOfAccountId,
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ExpenseCategory.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to create category');
  }

  // ==========================================
  // REQUISITIONS & APPROVALS
  // ==========================================
  Future<({List<Requisition> requisitions, RequisitionStats stats})> getRequisitions({
    String? status,
    bool? myRequests,
    String? search,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': 30};
    if (status != null && status != 'all') query['status'] = status;
    if (myRequests == true) query['my_requests'] = 1;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _dio.get('/requisitions', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      final rawData = response.data['data'];
      List items = [];
      if (rawData is List) {
        items = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        items = rawData['data'] as List;
      }

      final requisitions = items.map((json) => Requisition.fromJson(json as Map<String, dynamic>)).toList();
      final stats = response.data['stats'] != null
          ? RequisitionStats.fromJson(response.data['stats'] as Map<String, dynamic>)
          : const RequisitionStats();

      return (requisitions: requisitions, stats: stats);
    }
    return (requisitions: <Requisition>[], stats: const RequisitionStats());
  }

  Future<Requisition> createRequisition(Map<String, dynamic> data) async {
    final response = await _dio.post('/requisitions', data: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Requisition.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to submit requisition');
  }

  Future<Requisition> approveRequisition(String id, {String? comments, String? chartOfAccountId}) async {
    final payload = <String, dynamic>{};
    if (comments != null && comments.isNotEmpty) payload['comments'] = comments;
    if (chartOfAccountId != null) payload['chart_of_account_id'] = chartOfAccountId;

    final response = await _dio.post('/requisitions/$id/approve', data: payload);
    if (response.statusCode == 200) {
      return Requisition.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to approve requisition');
  }

  Future<Requisition> rejectRequisition(String id, {required String reason}) async {
    final response = await _dio.post('/requisitions/$id/reject', data: {'reason': reason});
    if (response.statusCode == 200) {
      return Requisition.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to reject requisition');
  }

  Future<Requisition> disburseRequisition(
    String id, {
    required String disbursementAccountId,
    String? paymentMethod,
  }) async {
    final payload = <String, dynamic>{
      'disbursement_account_id': disbursementAccountId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    };

    final response = await _dio.post('/requisitions/$id/disburse', data: payload);
    if (response.statusCode == 200) {
      return Requisition.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data['message'] ?? 'Failed to disburse requisition');
  }

  // ==========================================
  // REPORTS
  // ==========================================
  Future<ProfitAndLossReport> getProfitAndLoss({String? dateFrom, String? dateTo}) async {
    final query = <String, dynamic>{};
    if (dateFrom != null) query['date_from'] = dateFrom;
    if (dateTo != null) query['date_to'] = dateTo;

    final response = await _dio.get('/reports/profit-and-loss', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      return ProfitAndLossReport.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return const ProfitAndLossReport();
  }

  Future<TrialBalanceReport> getTrialBalance({String? asOf}) async {
    final query = <String, dynamic>{};
    if (asOf != null) query['as_of'] = asOf;

    final response = await _dio.get('/reports/trial-balance', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      return TrialBalanceReport.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return const TrialBalanceReport();
  }
}
