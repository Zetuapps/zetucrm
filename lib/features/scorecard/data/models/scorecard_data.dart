class ScorecardMetricItem {
  final int id;
  final String title;
  final String? description;
  final String timeframe;
  final String dataSource;
  final bool isAutoCrm;
  final String valueType; // boolean, number, currency, text
  final String targetOperator; // gte, lte, eq, boolean_true, text_any, range
  final String? targetValue;
  final String? unitLabel;
  final bool isUserSpecific;
  final String? userId;
  final String? assignedTo;
  final Map<String, dynamic>? assignedUser;
  final int? entryId;
  final dynamic currentValue;
  final bool? valueBoolean;
  final double? valueNumber;
  final String? valueText;
  final String? notes;
  final bool isAchieved;
  final int progressPercent;

  const ScorecardMetricItem({
    required this.id,
    required this.title,
    this.description,
    required this.timeframe,
    required this.dataSource,
    this.isAutoCrm = false,
    required this.valueType,
    required this.targetOperator,
    this.targetValue,
    this.unitLabel,
    this.isUserSpecific = false,
    this.userId,
    this.assignedTo,
    this.assignedUser,
    this.entryId,
    this.currentValue,
    this.valueBoolean,
    this.valueNumber,
    this.valueText,
    this.notes,
    this.isAchieved = false,
    this.progressPercent = 0,
  });

  factory ScorecardMetricItem.fromJson(Map<String, dynamic> json) {
    final ds = json['data_source']?.toString() ?? 'manual';
    final isAuto = json['is_auto_crm'] == true || ds.startsWith('crm_');

    double? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    int? parseNullableInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return null;
    }

    bool? parseBool(dynamic val) {
      if (val == null) return null;
      if (val is bool) return val;
      if (val == 1 || val == '1' || val == 'true') return true;
      if (val == 0 || val == '0' || val == 'false') return false;
      return null;
    }

    return ScorecardMetricItem(
      id: parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      timeframe: json['timeframe']?.toString() ?? 'daily',
      dataSource: ds,
      isAutoCrm: isAuto,
      valueType: json['value_type']?.toString().toLowerCase() ?? 'number',
      targetOperator: json['target_operator']?.toString() ?? 'gte',
      targetValue: json['target_value']?.toString(),
      unitLabel: json['unit_label']?.toString(),
      isUserSpecific: json['is_user_specific'] == true || json['is_user_specific'] == 1 || json['is_user_specific'] == '1',
      userId: json['user_id']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      assignedUser: json['assigned_user'] is Map ? Map<String, dynamic>.from(json['assigned_user'] as Map) : null,
      entryId: parseNullableInt(json['entry_id']),
      currentValue: json['current_value'],
      valueBoolean: parseBool(json['value_boolean']),
      valueNumber: parseNum(json['value_number']),
      valueText: json['value_text']?.toString(),
      notes: json['notes']?.toString(),
      isAchieved: json['is_achieved'] == true || json['is_achieved'] == 1 || json['is_achieved'] == '1',
      progressPercent: parseInt(json['progress_percent']),
    );
  }

  ScorecardMetricItem copyWith({
    dynamic currentValue,
    bool? valueBoolean,
    double? valueNumber,
    String? valueText,
    String? notes,
    bool? isAchieved,
    int? progressPercent,
  }) {
    return ScorecardMetricItem(
      id: id,
      title: title,
      description: description,
      timeframe: timeframe,
      dataSource: dataSource,
      isAutoCrm: isAutoCrm,
      valueType: valueType,
      targetOperator: targetOperator,
      targetValue: targetValue,
      unitLabel: unitLabel,
      isUserSpecific: isUserSpecific,
      userId: userId,
      assignedTo: assignedTo,
      assignedUser: assignedUser,
      entryId: entryId,
      currentValue: currentValue ?? this.currentValue,
      valueBoolean: valueBoolean ?? this.valueBoolean,
      valueNumber: valueNumber ?? this.valueNumber,
      valueText: valueText ?? this.valueText,
      notes: notes ?? this.notes,
      isAchieved: isAchieved ?? this.isAchieved,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}

class HistoryDay {
  final String date;
  final String dayName;
  final String dayFull;
  final bool isToday;
  final int totalMetrics;
  final int achievedMetrics;
  final int completionRate;

  const HistoryDay({
    required this.date,
    required this.dayName,
    required this.dayFull,
    this.isToday = false,
    this.totalMetrics = 0,
    this.achievedMetrics = 0,
    this.completionRate = 0,
  });

  factory HistoryDay.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    return HistoryDay(
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      dayFull: json['day_full']?.toString() ?? '',
      isToday: json['is_today'] == true || json['is_today'] == 1 || json['is_today'] == '1',
      totalMetrics: parseInt(json['total_metrics']),
      achievedMetrics: parseInt(json['achieved_metrics']),
      completionRate: parseInt(json['completion_rate']),
    );
  }
}

class ScorecardData {
  final String timeframe;
  final String periodLabel;
  final String startDate;
  final String endDate;
  final String targetDate;
  final bool isWorkingDay;
  final List<String> workingDays;
  final int totalMetrics;
  final int achievedMetrics;
  final int completionRate;
  final List<ScorecardMetricItem> metrics;

  const ScorecardData({
    required this.timeframe,
    required this.periodLabel,
    required this.startDate,
    required this.endDate,
    required this.targetDate,
    this.isWorkingDay = true,
    this.workingDays = const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
    this.totalMetrics = 0,
    this.achievedMetrics = 0,
    this.completionRate = 0,
    this.metrics = const [],
  });

  factory ScorecardData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(val);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    final rawMetrics = (json['metrics'] as List? ?? []);
    final workingDaysRaw = (json['working_days'] as List? ?? []);

    return ScorecardData(
      timeframe: json['timeframe']?.toString() ?? 'daily',
      periodLabel: json['period_label']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      targetDate: json['target_date']?.toString() ?? '',
      isWorkingDay: json['is_working_day'] != false && json['is_working_day'] != 0 && json['is_working_day'] != '0',
      workingDays: workingDaysRaw.map((e) => e.toString().toLowerCase()).toList(),
      totalMetrics: parseInt(json['total_metrics']),
      achievedMetrics: parseInt(json['achieved_metrics']),
      completionRate: parseInt(json['completion_rate']),
      metrics: rawMetrics
          .whereType<Map>()
          .map((m) => ScorecardMetricItem.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }

  ScorecardData copyWith({
    List<ScorecardMetricItem>? metrics,
    int? totalMetrics,
    int? achievedMetrics,
    int? completionRate,
  }) {
    return ScorecardData(
      timeframe: timeframe,
      periodLabel: periodLabel,
      startDate: startDate,
      endDate: endDate,
      targetDate: targetDate,
      isWorkingDay: isWorkingDay,
      workingDays: workingDays,
      totalMetrics: totalMetrics ?? this.totalMetrics,
      achievedMetrics: achievedMetrics ?? this.achievedMetrics,
      completionRate: completionRate ?? this.completionRate,
      metrics: metrics ?? this.metrics,
    );
  }
}
