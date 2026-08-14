import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';

class MetricItem {
  final int count;
  final double change;
  final String label;

  MetricItem({required this.count, required this.change, required this.label});

  factory MetricItem.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    final rawChange = json['change'];
    return MetricItem(
      count: rawCount is num
          ? rawCount.toInt()
          : (int.tryParse(rawCount?.toString() ?? '') ?? 0),
      change: rawChange is num
          ? rawChange.toDouble()
          : (double.tryParse(rawChange?.toString() ?? '') ?? 0.0),
      label: json['label']?.toString() ?? '',
    );
  }
}

class DashboardDeal {
  final String id;
  final String title;
  final String client;
  final double value;
  final String stage;

  DashboardDeal({
    required this.id,
    required this.title,
    required this.client,
    required this.value,
    required this.stage,
  });

  factory DashboardDeal.fromJson(Map<String, dynamic> json) {
    final rawVal = json['value'];
    return DashboardDeal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      client: json['client']?.toString() ?? '',
      value: rawVal is num
          ? rawVal.toDouble()
          : (double.tryParse(rawVal?.toString() ?? '') ?? 0.0),
      stage: json['stage']?.toString() ?? '',
    );
  }
}

class DashboardTask {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String dueTime;
  final String? contactName;

  DashboardTask({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.dueTime,
    this.contactName,
  });

  factory DashboardTask.fromJson(Map<String, dynamic> json) {
    return DashboardTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString() ?? 'medium',
      dueTime: json['due_time']?.toString() ?? 'Today',
      contactName: json['contact_name']?.toString(),
    );
  }
}

class ContactAvatarItem {
  final String id;
  final String name;
  final String shortName;
  final String? avatarUrl;
  final String initial;
  final String badge;
  final int priority;

  ContactAvatarItem({
    required this.id,
    required this.name,
    required this.shortName,
    this.avatarUrl,
    required this.initial,
    required this.badge,
    required this.priority,
  });

  factory ContactAvatarItem.fromJson(Map<String, dynamic> json) {
    return ContactAvatarItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName:
          json['short_name']?.toString() ?? json['name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      initial: json['initial']?.toString() ?? 'C',
      badge: json['badge']?.toString() ?? 'Lead',
      priority: (json['priority'] as num?)?.toInt() ?? 3,
    );
  }
}

class DashboardData {
  final String userName;
  final String companyName;
  final MetricItem newLeads;
  final MetricItem customerNetwork;
  final MetricItem deals;
  final MetricItem customers;
  final double pipelineValue;
  final double closedRevenue;
  final int todayNewCount;
  final List<ContactAvatarItem> todayNewContacts;
  final List<DashboardTask> tasksDueToday;
  final List<DashboardDeal> activeDeals;

  DashboardData({
    required this.userName,
    required this.companyName,
    required this.newLeads,
    required this.customerNetwork,
    required this.deals,
    required this.customers,
    required this.pipelineValue,
    required this.closedRevenue,
    required this.todayNewCount,
    required this.todayNewContacts,
    required this.tasksDueToday,
    required this.activeDeals,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final d = json['data'] ?? {};
    final rawPipeValue = d['pipelineValue'];
    final rawClosedRev = d['closedRevenue'];
    final rawTodayCount = d['todayNewCount'];

    return DashboardData(
      userName: json['userName']?.toString() ?? 'User',
      companyName: json['companyName']?.toString() ?? 'ZetuCRM',
      newLeads: MetricItem.fromJson(d['newLeads'] ?? {}),
      customerNetwork: MetricItem.fromJson(d['customerNetwork'] ?? {}),
      deals: MetricItem.fromJson(d['deals'] ?? {}),
      customers: MetricItem.fromJson(d['customers'] ?? {}),
      pipelineValue: rawPipeValue is num
          ? rawPipeValue.toDouble()
          : (double.tryParse(rawPipeValue?.toString() ?? '') ?? 0.0),
      closedRevenue: rawClosedRev is num
          ? rawClosedRev.toDouble()
          : (double.tryParse(rawClosedRev?.toString() ?? '') ?? 0.0),
      todayNewCount: rawTodayCount is num
          ? rawTodayCount.toInt()
          : (int.tryParse(rawTodayCount?.toString() ?? '') ?? 0),
      todayNewContacts: (d['todayNewContacts'] as List? ?? [])
          .map((c) => ContactAvatarItem.fromJson(c))
          .toList(),
      tasksDueToday: (d['tasksDueToday'] as List? ?? [])
          .map((t) => DashboardTask.fromJson(t))
          .toList(),
      activeDeals: (d['activeDeals'] as List? ?? [])
          .map((item) => DashboardDeal.fromJson(item))
          .toList(),
    );
  }
}

class SelectedRangeNotifier extends Notifier<String> {
  @override
  String build() => 'Last 30 days';

  void setRange(String range) {
    state = range;
  }
}

final selectedRangeProvider =
    NotifierProvider<SelectedRangeNotifier, String>(SelectedRangeNotifier.new);

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  FutureOr<DashboardData> build() async {
    final apiClient = ref.watch(apiClientProvider);
    final range = ref.watch(selectedRangeProvider);

    String rangeParam = '30_days';
    if (range == 'This Month') rangeParam = '30_days';
    if (range == '3 Months') rangeParam = '3_months';
    if (range == 'Year') rangeParam = 'year';

    final res = await apiClient.dio.get(
      '/dashboard',
      queryParameters: {'range': rangeParam},
    );

    if (res.statusCode == 200 && res.data != null) {
      return DashboardData.fromJson(res.data);
    }
    throw Exception(
      'Failed to load dashboard data from API (${res.statusCode})',
    );
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);
