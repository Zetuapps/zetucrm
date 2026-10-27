import '../../../core/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/scorecard_data.dart';
import '../data/scorecard_repository.dart';

final scorecardRepositoryProvider = Provider<ScorecardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScorecardRepository(apiClient: apiClient);
});

class ScorecardState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String timeframe; // daily, weekly, monthly, quarterly, annually
  final DateTime targetDate;
  final ScorecardData? scorecard;
  final List<HistoryDay> history;
  final List<ScorecardMetricItem> allMetrics;
  final Map<String, dynamic>? crmMeta;

  const ScorecardState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.timeframe = 'daily',
    required this.targetDate,
    this.scorecard,
    this.history = const [],
    this.allMetrics = const [],
    this.crmMeta,
  });

  ScorecardState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? timeframe,
    DateTime? targetDate,
    ScorecardData? scorecard,
    List<HistoryDay>? history,
    List<ScorecardMetricItem>? allMetrics,
    Map<String, dynamic>? crmMeta,
  }) {
    return ScorecardState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      timeframe: timeframe ?? this.timeframe,
      targetDate: targetDate ?? this.targetDate,
      scorecard: scorecard ?? this.scorecard,
      history: history ?? this.history,
      allMetrics: allMetrics ?? this.allMetrics,
      crmMeta: crmMeta ?? this.crmMeta,
    );
  }
}

class ScorecardNotifier extends Notifier<ScorecardState> {
  ScorecardRepository get _repo => ref.read(scorecardRepositoryProvider);

  @override
  ScorecardState build() {
    Future.microtask(() => loadScorecard());
    return ScorecardState(targetDate: DateTime.now());
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(state.targetDate);

  Future<void> loadScorecard({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final res = await _repo.getScorecard(
        timeframe: state.timeframe,
        date: _formattedDate,
      );
      state = state.copyWith(
        isLoading: false,
        scorecard: res.scorecard,
        history: res.history,
        allMetrics: res.allMetrics,
        crmMeta: res.crmMeta,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setTimeframe(String tf) {
    if (state.timeframe == tf) return;
    state = state.copyWith(timeframe: tf);
    loadScorecard();
  }

  void setDate(DateTime dt) {
    state = state.copyWith(targetDate: dt);
    loadScorecard();
  }

  void goToToday() {
    state = state.copyWith(targetDate: DateTime.now());
    loadScorecard();
  }

  void previousPeriod() {
    DateTime next;
    switch (state.timeframe) {
      case 'weekly':
        next = state.targetDate.subtract(const Duration(days: 7));
        break;
      case 'monthly':
        next = DateTime(state.targetDate.year, state.targetDate.month - 1, state.targetDate.day);
        break;
      case 'quarterly':
        next = DateTime(state.targetDate.year, state.targetDate.month - 3, state.targetDate.day);
        break;
      case 'annually':
        next = DateTime(state.targetDate.year - 1, state.targetDate.month, state.targetDate.day);
        break;
      case 'daily':
      default:
        next = state.targetDate.subtract(const Duration(days: 1));
        break;
    }
    state = state.copyWith(targetDate: next);
    loadScorecard();
  }

  void nextPeriod() {
    DateTime next;
    switch (state.timeframe) {
      case 'weekly':
        next = state.targetDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        next = DateTime(state.targetDate.year, state.targetDate.month + 1, state.targetDate.day);
        break;
      case 'quarterly':
        next = DateTime(state.targetDate.year, state.targetDate.month + 3, state.targetDate.day);
        break;
      case 'annually':
        next = DateTime(state.targetDate.year + 1, state.targetDate.month, state.targetDate.day);
        break;
      case 'daily':
      default:
        next = state.targetDate.add(const Duration(days: 1));
        break;
    }
    state = state.copyWith(targetDate: next);
    loadScorecard();
  }

  /// Optimistic toggle for boolean metrics (Yes / No)
  Future<void> toggleBoolean(ScorecardMetricItem metric) async {
    final sc = state.scorecard;
    if (sc == null) return;

    final nextVal = !(metric.valueBoolean ?? false);
    final updatedList = sc.metrics.map((m) {
      if (m.id == metric.id) {
        return m.copyWith(
          valueBoolean: nextVal,
          currentValue: nextVal,
          isAchieved: nextVal,
          progressPercent: nextVal ? 100 : 0,
        );
      }
      return m;
    }).toList();

    final achievedCount = updatedList.where((m) => m.isAchieved).length;
    final totalCount = updatedList.length;
    final compRate = totalCount > 0 ? ((achievedCount / totalCount) * 100).round() : 0;

    state = state.copyWith(
      scorecard: sc.copyWith(
        metrics: updatedList,
        achievedMetrics: achievedCount,
        completionRate: compRate,
      ),
    );

    try {
      await _repo.saveEntry(
        metricId: metric.id,
        valueBoolean: nextVal,
        periodDate: sc.targetDate.isNotEmpty ? sc.targetDate : _formattedDate,
      );
      await loadScorecard(showLoading: false);
    } catch (_) {
      loadScorecard(showLoading: false);
    }
  }

  /// Optimistic step for numeric / counter metrics (+1 / -1)
  Future<void> stepNumber(ScorecardMetricItem metric, double delta) async {
    final sc = state.scorecard;
    if (sc == null) return;

    final current = metric.valueNumber ??
        (metric.currentValue is num
            ? (metric.currentValue as num).toDouble()
            : (double.tryParse(metric.currentValue?.toString() ?? '') ?? 0.0));
    final nextVal = (current + delta) < 0 ? 0.0 : (current + delta);
    final target = double.tryParse(metric.targetValue ?? '1') ?? 1.0;

    final bool isAchieved;
    if (metric.targetOperator == 'lte') {
      isAchieved = nextVal > 0 && nextVal <= target;
    } else {
      isAchieved = nextVal >= target;
    }
    final int progress = isAchieved
        ? 100
        : target > 0
            ? ((nextVal / target) * 100).clamp(0, 100).round()
            : 0;

    final updatedList = sc.metrics.map((m) {
      if (m.id == metric.id) {
        return m.copyWith(
          valueNumber: nextVal,
          currentValue: nextVal,
          isAchieved: isAchieved,
          progressPercent: progress,
        );
      }
      return m;
    }).toList();

    final achievedCount = updatedList.where((m) => m.isAchieved).length;
    final totalCount = updatedList.length;
    final compRate = totalCount > 0 ? ((achievedCount / totalCount) * 100).round() : 0;

    state = state.copyWith(
      scorecard: sc.copyWith(
        metrics: updatedList,
        achievedMetrics: achievedCount,
        completionRate: compRate,
      ),
    );

    try {
      await _repo.saveEntry(
        metricId: metric.id,
        valueNumber: nextVal,
        periodDate: sc.targetDate.isNotEmpty ? sc.targetDate : _formattedDate,
      );
      await loadScorecard(showLoading: false);
    } catch (_) {
      loadScorecard(showLoading: false);
    }
  }

  /// Save direct manual entry (with optional notes)
  Future<void> saveEntry({
    required int metricId,
    double? valueNumber,
    bool? valueBoolean,
    String? valueText,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true);
    final sc = state.scorecard;
    try {
      await _repo.saveEntry(
        metricId: metricId,
        valueNumber: valueNumber,
        valueBoolean: valueBoolean,
        valueText: valueText,
        notes: notes,
        periodDate: sc?.targetDate.isNotEmpty == true ? sc!.targetDate : _formattedDate,
      );
      await loadScorecard(showLoading: false);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> createMetric(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repo.storeMetric(data);
      await loadScorecard();
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> deleteMetric(int metricId) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repo.destroyMetric(metricId);
      await loadScorecard();
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final scorecardProvider = NotifierProvider<ScorecardNotifier, ScorecardState>(() {
  return ScorecardNotifier();
});
