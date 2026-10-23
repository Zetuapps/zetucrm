class RequisitionApprovalItem {
  final String id;
  final int stepOrder;
  final String status; // pending, approved, rejected
  final String? approverName;
  final String? comments;
  final String? actionedAt;

  const RequisitionApprovalItem({
    required this.id,
    required this.stepOrder,
    required this.status,
    this.approverName,
    this.comments,
    this.actionedAt,
  });

  factory RequisitionApprovalItem.fromJson(Map<String, dynamic> json) {
    String? approver;
    if (json['approver'] is Map) {
      final a = json['approver'] as Map<String, dynamic>;
      final first = a['first_name'] ?? a['name'] ?? '';
      final last = a['last_name'] ?? '';
      approver = '$first $last'.trim();
    }

    return RequisitionApprovalItem(
      id: json['id']?.toString() ?? '',
      stepOrder: (json['step_order'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      approverName: approver,
      comments: json['comments']?.toString(),
      actionedAt: json['actioned_at']?.toString(),
    );
  }
}

class RequisitionStats {
  final int totalCount;
  final int pendingCount;
  final double pendingAmount;
  final int approvedCount;
  final double approvedAmount;
  final int disbursedCount;
  final double disbursedAmount;

  const RequisitionStats({
    this.totalCount = 0,
    this.pendingCount = 0,
    this.pendingAmount = 0.0,
    this.approvedCount = 0,
    this.approvedAmount = 0.0,
    this.disbursedCount = 0,
    this.disbursedAmount = 0.0,
  });

  factory RequisitionStats.fromJson(Map<String, dynamic> json) {
    final rawTot = json['total_count'];
    final rawPendC = json['pending_count'];
    final rawPendA = json['pending_amount'];
    final rawAppC = json['approved_count'];
    final rawAppA = json['approved_amount'];
    final rawDisbC = json['disbursed_count'];
    final rawDisbA = json['disbursed_amount'];

    return RequisitionStats(
      totalCount: rawTot is num ? rawTot.toInt() : (int.tryParse(rawTot?.toString() ?? '') ?? 0),
      pendingCount: rawPendC is num ? rawPendC.toInt() : (int.tryParse(rawPendC?.toString() ?? '') ?? 0),
      pendingAmount: rawPendA is num ? rawPendA.toDouble() : (double.tryParse(rawPendA?.toString() ?? '') ?? 0.0),
      approvedCount: rawAppC is num ? rawAppC.toInt() : (int.tryParse(rawAppC?.toString() ?? '') ?? 0),
      approvedAmount: rawAppA is num ? rawAppA.toDouble() : (double.tryParse(rawAppA?.toString() ?? '') ?? 0.0),
      disbursedCount: rawDisbC is num ? rawDisbC.toInt() : (int.tryParse(rawDisbC?.toString() ?? '') ?? 0),
      disbursedAmount: rawDisbA is num ? rawDisbA.toDouble() : (double.tryParse(rawDisbA?.toString() ?? '') ?? 0.0),
    );
  }
}

class Requisition {
  final String id;
  final String requisitionNumber;
  final String title;
  final String? purpose;
  final double amount;
  final String currency;
  final double? originalAmount;
  final double exchangeRate;
  final String status; // submitted, pending_approval, approved, rejected, disbursed
  final String paymentMethod;
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientAccountNumber;
  final String? recipientBankName;
  final int currentStepOrder;
  final String? chartOfAccountId;
  final String? expenseAccountName;
  final String? disbursementAccountId;
  final String? disbursementAccountName;
  final String? requesterName;
  final String? requesterEmail;
  final bool canApprove;
  final bool canDisburse;
  final String? createdAt;
  final String? rejectionReason;
  final List<RequisitionApprovalItem> approvals;

  const Requisition({
    required this.id,
    required this.requisitionNumber,
    required this.title,
    this.purpose,
    required this.amount,
    this.currency = 'TZS',
    this.originalAmount,
    this.exchangeRate = 1.0,
    required this.status,
    this.paymentMethod = 'cash',
    this.recipientName,
    this.recipientPhone,
    this.recipientAccountNumber,
    this.recipientBankName,
    this.currentStepOrder = 1,
    this.chartOfAccountId,
    this.expenseAccountName,
    this.disbursementAccountId,
    this.disbursementAccountName,
    this.requesterName,
    this.requesterEmail,
    this.canApprove = false,
    this.canDisburse = false,
    this.createdAt,
    this.rejectionReason,
    this.approvals = const [],
  });

  factory Requisition.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final rawOrig = json['original_amount'];
    final rawRate = json['exchange_rate'];

    String? reqName;
    String? reqEmail;
    if (json['requester'] is Map) {
      final r = json['requester'] as Map<String, dynamic>;
      final first = r['first_name'] ?? '';
      final last = r['last_name'] ?? '';
      reqName = '$first $last'.trim();
      reqEmail = r['email']?.toString();
    }

    String? expAcc;
    if (json['expense_account'] is Map) {
      expAcc = json['expense_account']['name']?.toString();
    }

    String? disbAcc;
    if (json['disbursement_account'] is Map) {
      disbAcc = json['disbursement_account']['name']?.toString();
    }

    return Requisition(
      id: json['id']?.toString() ?? '',
      requisitionNumber: json['requisition_number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      purpose: json['purpose']?.toString(),
      amount: rawAmount is num
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount?.toString() ?? '') ?? 0.0),
      currency: json['currency']?.toString().toUpperCase() ?? 'TZS',
      originalAmount: rawOrig is num
          ? rawOrig.toDouble()
          : (double.tryParse(rawOrig?.toString() ?? '')),
      exchangeRate: rawRate is num
          ? rawRate.toDouble()
          : (double.tryParse(rawRate?.toString() ?? '') ?? 1.0),
      status: json['status']?.toString().toLowerCase() ?? 'pending_approval',
      paymentMethod: json['payment_method']?.toString().toLowerCase() ?? 'cash',
      recipientName: json['recipient_name']?.toString(),
      recipientPhone: json['recipient_phone']?.toString(),
      recipientAccountNumber: json['recipient_account_number']?.toString(),
      recipientBankName: json['recipient_bank_name']?.toString(),
      currentStepOrder: (json['current_step_order'] as num?)?.toInt() ?? 1,
      chartOfAccountId: json['chart_of_account_id']?.toString(),
      expenseAccountName: expAcc,
      disbursementAccountId: json['disbursement_account_id']?.toString(),
      disbursementAccountName: disbAcc,
      requesterName: reqName,
      requesterEmail: reqEmail,
      canApprove: json['can_approve'] == true || json['can_approve'] == 1,
      canDisburse: json['can_disburse'] == true || json['can_disburse'] == 1,
      createdAt: json['created_at']?.toString().split('T').first,
      rejectionReason: json['rejection_reason']?.toString(),
      approvals: (json['approvals'] as List? ?? [])
          .map((a) => RequisitionApprovalItem.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isPending => status == 'submitted' || status == 'pending_approval';
  bool get isApproved => status == 'approved';
  bool get isDisbursed => status == 'disbursed';
  bool get isRejected => status == 'rejected';
}
