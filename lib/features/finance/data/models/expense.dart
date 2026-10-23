import 'chart_of_account.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final String? chartOfAccountId;
  final ChartOfAccount? chartOfAccount;

  const ExpenseCategory({
    required this.id,
    required this.name,
    this.chartOfAccountId,
    this.chartOfAccount,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      chartOfAccountId: json['chart_of_account_id']?.toString(),
      chartOfAccount: json['chart_of_account'] != null
          ? ChartOfAccount.fromJson(json['chart_of_account'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'chart_of_account_id': chartOfAccountId,
  };
}

class ExpenseStats {
  final double totalAmount;
  final int totalCount;
  final double pendingAmount;
  final int pendingCount;
  final double thisMonthAmount;

  const ExpenseStats({
    this.totalAmount = 0.0,
    this.totalCount = 0,
    this.pendingAmount = 0.0,
    this.pendingCount = 0,
    this.thisMonthAmount = 0.0,
  });

  factory ExpenseStats.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total_amount'];
    final rawTotalC = json['total_count'];
    final rawPend = json['pending_amount'];
    final rawPendC = json['pending_count'];
    final rawMonth = json['this_month_amount'];

    return ExpenseStats(
      totalAmount: rawTotal is num
          ? rawTotal.toDouble()
          : (double.tryParse(rawTotal?.toString() ?? '') ?? 0.0),
      totalCount: rawTotalC is num
          ? rawTotalC.toInt()
          : (int.tryParse(rawTotalC?.toString() ?? '') ?? 0),
      pendingAmount: rawPend is num
          ? rawPend.toDouble()
          : (double.tryParse(rawPend?.toString() ?? '') ?? 0.0),
      pendingCount: rawPendC is num
          ? rawPendC.toInt()
          : (int.tryParse(rawPendC?.toString() ?? '') ?? 0),
      thisMonthAmount: rawMonth is num
          ? rawMonth.toDouble()
          : (double.tryParse(rawMonth?.toString() ?? '') ?? 0.0),
    );
  }
}

class Expense {
  final String id;
  final double amount;
  final String currency;
  final double? originalAmount;
  final double exchangeRate;
  final String description;
  final String expenseDate;
  final String paymentMethod; // cash, mpesa, bank_transfer, credit_card, cheque
  final String status; // pending, approved, rejected
  final String? expenseCategoryId;
  final String? categoryName;
  final String? chartOfAccountId;
  final String? expenseAccountName;
  final String? expenseAccountCode;
  final String? paymentAccountId;
  final String? paymentAccountName;
  final String? paymentAccountCode;
  final String? approverName;
  final String? creatorName;
  final String? approvedAt;

  const Expense({
    required this.id,
    required this.amount,
    this.currency = 'TZS',
    this.originalAmount,
    this.exchangeRate = 1.0,
    required this.description,
    required this.expenseDate,
    required this.paymentMethod,
    required this.status,
    this.expenseCategoryId,
    this.categoryName,
    this.chartOfAccountId,
    this.expenseAccountName,
    this.expenseAccountCode,
    this.paymentAccountId,
    this.paymentAccountName,
    this.paymentAccountCode,
    this.approverName,
    this.creatorName,
    this.approvedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final rawOriginal = json['original_amount'];
    final rawRate = json['exchange_rate'];

    String? catName;
    if (json['category'] is Map) {
      catName = json['category']['name']?.toString();
    }

    String? expAccName;
    String? expAccCode;
    if (json['chart_of_account'] is Map) {
      expAccName = json['chart_of_account']['name']?.toString();
      expAccCode = json['chart_of_account']['account_code']?.toString();
    }

    String? payAccName;
    String? payAccCode;
    if (json['payment_account'] is Map) {
      payAccName = json['payment_account']['name']?.toString();
      payAccCode = json['payment_account']['account_code']?.toString();
    }

    String? approver;
    if (json['approver'] is Map) {
      final a = json['approver'] as Map<String, dynamic>;
      final first = a['first_name'] ?? a['name'] ?? '';
      final last = a['last_name'] ?? '';
      approver = '$first $last'.trim();
    }

    String? creator;
    if (json['creator'] is Map) {
      final c = json['creator'] as Map<String, dynamic>;
      final first = c['first_name'] ?? c['name'] ?? '';
      final last = c['last_name'] ?? '';
      creator = '$first $last'.trim();
    }

    return Expense(
      id: json['id']?.toString() ?? '',
      amount: rawAmount is num
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount?.toString() ?? '') ?? 0.0),
      currency: json['currency']?.toString().toUpperCase() ?? 'TZS',
      originalAmount: rawOriginal is num
          ? rawOriginal.toDouble()
          : (double.tryParse(rawOriginal?.toString() ?? '')),
      exchangeRate: rawRate is num
          ? rawRate.toDouble()
          : (double.tryParse(rawRate?.toString() ?? '') ?? 1.0),
      description: json['description']?.toString() ?? '',
      expenseDate: json['expense_date']?.toString().split('T').first ?? '',
      paymentMethod: json['payment_method']?.toString().toLowerCase() ?? 'cash',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      expenseCategoryId: json['expense_category_id']?.toString(),
      categoryName: catName,
      chartOfAccountId: json['chart_of_account_id']?.toString(),
      expenseAccountName: expAccName,
      expenseAccountCode: expAccCode,
      paymentAccountId: json['payment_account_id']?.toString(),
      paymentAccountName: payAccName,
      paymentAccountCode: payAccCode,
      approverName: approver,
      creatorName: creator,
      approvedAt: json['approved_at']?.toString(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
