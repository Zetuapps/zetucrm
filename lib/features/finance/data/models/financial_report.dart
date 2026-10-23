class FinancialReportRow {
  final String accountCode;
  final String accountName;
  final double amount;
  final double debit;
  final double credit;

  const FinancialReportRow({
    required this.accountCode,
    required this.accountName,
    this.amount = 0.0,
    this.debit = 0.0,
    this.credit = 0.0,
  });

  factory FinancialReportRow.fromJson(Map<String, dynamic> json) {
    final rawAmt = json['amount'] ?? json['balance'];
    final rawDebit = json['debit'];
    final rawCredit = json['credit'];

    return FinancialReportRow(
      accountCode: json['account_code']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? json['name']?.toString() ?? '',
      amount: rawAmt is num ? rawAmt.toDouble() : (double.tryParse(rawAmt?.toString() ?? '') ?? 0.0),
      debit: rawDebit is num ? rawDebit.toDouble() : (double.tryParse(rawDebit?.toString() ?? '') ?? 0.0),
      credit: rawCredit is num ? rawCredit.toDouble() : (double.tryParse(rawCredit?.toString() ?? '') ?? 0.0),
    );
  }
}

class ProfitAndLossReport {
  final double totalRevenue;
  final double totalExpenses;
  final double netIncome;
  final List<FinancialReportRow> revenueItems;
  final List<FinancialReportRow> expenseItems;

  const ProfitAndLossReport({
    this.totalRevenue = 0.0,
    this.totalExpenses = 0.0,
    this.netIncome = 0.0,
    this.revenueItems = const [],
    this.expenseItems = const [],
  });

  factory ProfitAndLossReport.fromJson(Map<String, dynamic> json) {
    final rawRev = json['total_revenue'] ?? json['revenue_total'];
    final rawExp = json['total_expense'] ?? json['expense_total'] ?? json['total_expenses'];
    final rawNet = json['net_income'] ?? json['net_profit'];

    List<FinancialReportRow> parseRows(dynamic list) {
      if (list is List) {
        return list.map((item) => FinancialReportRow.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return ProfitAndLossReport(
      totalRevenue: rawRev is num ? rawRev.toDouble() : (double.tryParse(rawRev?.toString() ?? '') ?? 0.0),
      totalExpenses: rawExp is num ? rawExp.toDouble() : (double.tryParse(rawExp?.toString() ?? '') ?? 0.0),
      netIncome: rawNet is num ? rawNet.toDouble() : (double.tryParse(rawNet?.toString() ?? '') ?? 0.0),
      revenueItems: parseRows(json['revenues'] ?? json['revenue_accounts']),
      expenseItems: parseRows(json['expenses'] ?? json['expense_accounts']),
    );
  }
}

class TrialBalanceReport {
  final double totalDebits;
  final double totalCredits;
  final bool isBalanced;
  final List<FinancialReportRow> rows;

  const TrialBalanceReport({
    this.totalDebits = 0.0,
    this.totalCredits = 0.0,
    this.isBalanced = true,
    this.rows = const [],
  });

  factory TrialBalanceReport.fromJson(Map<String, dynamic> json) {
    final rawDeb = json['total_debit'] ?? json['total_debits'];
    final rawCred = json['total_credit'] ?? json['total_credits'];

    List<FinancialReportRow> rows = [];
    final accounts = json['accounts'] ?? json['items'] ?? json['data'];
    if (accounts is List) {
      rows = accounts.map((a) => FinancialReportRow.fromJson(a as Map<String, dynamic>)).toList();
    }

    final deb = rawDeb is num ? rawDeb.toDouble() : (double.tryParse(rawDeb?.toString() ?? '') ?? 0.0);
    final cred = rawCred is num ? rawCred.toDouble() : (double.tryParse(rawCred?.toString() ?? '') ?? 0.0);

    return TrialBalanceReport(
      totalDebits: deb,
      totalCredits: cred,
      isBalanced: (deb - cred).abs() < 0.05,
      rows: rows,
    );
  }
}
