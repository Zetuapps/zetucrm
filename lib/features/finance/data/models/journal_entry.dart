import 'chart_of_account.dart';

class JournalEntryLine {
  final String id;
  final String chartOfAccountId;
  final String type; // debit or credit
  final double amount;
  final String? description;
  final ChartOfAccount? account;

  const JournalEntryLine({
    required this.id,
    required this.chartOfAccountId,
    required this.type,
    required this.amount,
    this.description,
    this.account,
  });

  factory JournalEntryLine.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    return JournalEntryLine(
      id: json['id']?.toString() ?? '',
      chartOfAccountId: json['chart_of_account_id']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'debit',
      amount: rawAmount is num
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount?.toString() ?? '') ?? 0.0),
      description: json['description']?.toString(),
      account: json['account'] != null
          ? ChartOfAccount.fromJson(json['account'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chart_of_account_id': chartOfAccountId,
      'type': type,
      'amount': amount,
      'description': description,
    };
  }
}

class JournalEntry {
  final String id;
  final String entryDate;
  final String? referenceNumber;
  final String? description;
  final String currency;
  final double? originalAmount;
  final double exchangeRate;
  final String status; // posted, draft, reversed
  final String? creatorName;
  final List<JournalEntryLine> lines;

  const JournalEntry({
    required this.id,
    required this.entryDate,
    this.referenceNumber,
    this.description,
    this.currency = 'TZS',
    this.originalAmount,
    this.exchangeRate = 1.0,
    this.status = 'posted',
    this.creatorName,
    this.lines = const [],
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final rawOrig = json['original_amount'];
    final rawRate = json['exchange_rate'];

    String? creator;
    if (json['creator'] is Map) {
      final c = json['creator'] as Map<String, dynamic>;
      final first = c['first_name'] ?? '';
      final last = c['last_name'] ?? '';
      creator = '$first $last'.trim();
    }

    return JournalEntry(
      id: json['id']?.toString() ?? '',
      entryDate: json['entry_date']?.toString().split('T').first ?? '',
      referenceNumber: json['reference_number']?.toString(),
      description: json['description']?.toString(),
      currency: json['currency']?.toString().toUpperCase() ?? 'TZS',
      originalAmount: rawOrig is num
          ? rawOrig.toDouble()
          : (double.tryParse(rawOrig?.toString() ?? '')),
      exchangeRate: rawRate is num
          ? rawRate.toDouble()
          : (double.tryParse(rawRate?.toString() ?? '') ?? 1.0),
      status: json['status']?.toString().toLowerCase() ?? 'posted',
      creatorName: creator,
      lines: (json['lines'] as List? ?? [])
          .map((l) => JournalEntryLine.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  double get totalDebit => lines
      .where((l) => l.type == 'debit')
      .fold(0.0, (sum, l) => sum + l.amount);

  double get totalCredit => lines
      .where((l) => l.type == 'credit')
      .fold(0.0, (sum, l) => sum + l.amount);
}

class GeneralLedgerLine {
  final String id;
  final String date;
  final String reference;
  final String accountName;
  final String accountCode;
  final String accountType;
  final String description;
  final double debit;
  final double credit;
  final double runningBalance;
  final String? currency;

  const GeneralLedgerLine({
    required this.id,
    required this.date,
    required this.reference,
    required this.accountName,
    required this.accountCode,
    required this.accountType,
    required this.description,
    required this.debit,
    required this.credit,
    this.runningBalance = 0.0,
    this.currency,
  });

  factory GeneralLedgerLine.fromJson(Map<String, dynamic> json) {
    final rawDebit = json['debit'];
    final rawCredit = json['credit'];
    final rawBal = json['running_balance'];

    return GeneralLedgerLine(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      reference: json['reference']?.toString() ?? json['reference_number']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      accountCode: json['account_code']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      debit: rawDebit is num
          ? rawDebit.toDouble()
          : (double.tryParse(rawDebit?.toString() ?? '') ?? 0.0),
      credit: rawCredit is num
          ? rawCredit.toDouble()
          : (double.tryParse(rawCredit?.toString() ?? '') ?? 0.0),
      runningBalance: rawBal is num
          ? rawBal.toDouble()
          : (double.tryParse(rawBal?.toString() ?? '') ?? 0.0),
      currency: json['currency']?.toString(),
    );
  }
}
