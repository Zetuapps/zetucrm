class ChartOfAccount {
  final String id;
  final String accountCode;
  final String name;
  final String type; // asset, liability, equity, revenue, expense
  final String? subType;
  final String? parentId;
  final String? description;
  final double openingBalance;
  final double currentBalance;
  final bool isActive;
  final bool isSystem;
  final List<ChartOfAccount> children;

  const ChartOfAccount({
    required this.id,
    required this.accountCode,
    required this.name,
    required this.type,
    this.subType,
    this.parentId,
    this.description,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
    this.isSystem = false,
    this.children = const [],
  });

  factory ChartOfAccount.fromJson(Map<String, dynamic> json) {
    final rawOpening = json['opening_balance'];
    final rawCurrent = json['current_balance'];

    return ChartOfAccount(
      id: json['id']?.toString() ?? '',
      accountCode: json['account_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'asset',
      subType: json['sub_type']?.toString(),
      parentId: json['parent_id']?.toString(),
      description: json['description']?.toString(),
      openingBalance: rawOpening is num
          ? rawOpening.toDouble()
          : (double.tryParse(rawOpening?.toString() ?? '') ?? 0.0),
      currentBalance: rawCurrent is num
          ? rawCurrent.toDouble()
          : (double.tryParse(rawCurrent?.toString() ?? '') ?? 0.0),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isSystem: json['is_system'] == true || json['is_system'] == 1,
      children: (json['children'] as List? ?? [])
          .map((c) => ChartOfAccount.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_code': accountCode,
      'name': name,
      'type': type,
      'sub_type': subType,
      'parent_id': parentId,
      'description': description,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'is_active': isActive,
      'is_system': isSystem,
    };
  }

  String get displayName => '$accountCode - $name';
}
