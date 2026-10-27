import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/scorecard_data.dart';

class ScorecardResponse {
  final ScorecardData scorecard;
  final List<HistoryDay> history;
  final List<ScorecardMetricItem> allMetrics;
  final Map<String, dynamic>? crmMeta;

  const ScorecardResponse({
    required this.scorecard,
    this.history = const [],
    this.allMetrics = const [],
    this.crmMeta,
  });
}

class ScorecardRepository {
  final ApiClient apiClient;

  ScorecardRepository({required this.apiClient});

  Dio get _dio => apiClient.dio;

  Future<ScorecardResponse> getScorecard({
    String timeframe = 'daily',
    String? date,
    String? special,
  }) async {
    final query = <String, dynamic>{'timeframe': timeframe};
    if (date != null && date.isNotEmpty) query['date'] = date;
    if (special != null && special.isNotEmpty) query['special'] = special;

    final response = await _dio.get('/scorecard', queryParameters: query);
    if (response.statusCode == 200 && response.data != null) {
      final rawData = response.data;
      final json = rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{};
      final scRaw = json['scorecard'];
      final scJson = scRaw is Map ? Map<String, dynamic>.from(scRaw) : <String, dynamic>{};
      final histList = (json['history'] as List? ?? [])
          .whereType<Map>()
          .map((h) => HistoryDay.fromJson(Map<String, dynamic>.from(h)))
          .toList();
      final allMetricsList = (json['all_metrics'] as List? ?? [])
          .whereType<Map>()
          .map((m) => ScorecardMetricItem.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      final crmMetaRaw = json['crm_meta'];
      final crmMeta = crmMetaRaw is Map ? Map<String, dynamic>.from(crmMetaRaw) : null;

      return ScorecardResponse(
        scorecard: ScorecardData.fromJson(scJson),
        history: histList,
        allMetrics: allMetricsList,
        crmMeta: crmMeta,
      );
    }
    throw Exception(response.data?['message'] ?? 'Failed to load scorecard data');
  }

  Future<void> saveEntry({
    required int metricId,
    String? periodDate,
    bool? valueBoolean,
    double? valueNumber,
    String? valueText,
    dynamic value,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'metric_id': metricId,
    };
    if (periodDate != null) payload['period_date'] = periodDate;
    if (valueBoolean != null) payload['value_boolean'] = valueBoolean;
    if (valueNumber != null) payload['value_number'] = valueNumber;
    if (valueText != null) payload['value_text'] = valueText;
    if (value != null && valueBoolean == null && valueNumber == null && valueText == null) {
      payload['value'] = value;
    }
    if (notes != null) payload['notes'] = notes;

    final response = await _dio.post('/scorecard/entry', data: payload);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.data?['message'] ?? 'Failed to save score entry');
    }
  }

  Future<ScorecardMetricItem> storeMetric(Map<String, dynamic> data) async {
    final response = await _dio.post('/scorecard/metrics', data: data);
    if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
      final metricJson = response.data['metric'] as Map<String, dynamic>;
      return ScorecardMetricItem.fromJson(metricJson);
    }
    throw Exception(response.data?['message'] ?? 'Failed to create scorecard metric');
  }

  Future<ScorecardMetricItem> updateMetric(int metricId, Map<String, dynamic> data) async {
    final response = await _dio.put('/scorecard/metrics/$metricId', data: data);
    if (response.statusCode == 200 && response.data != null) {
      final metricJson = response.data['metric'] as Map<String, dynamic>;
      return ScorecardMetricItem.fromJson(metricJson);
    }
    throw Exception(response.data?['message'] ?? 'Failed to update scorecard metric');
  }

  Future<void> destroyMetric(int metricId) async {
    final response = await _dio.delete('/scorecard/metrics/$metricId');
    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? 'Failed to delete scorecard metric');
    }
  }

  Future<void> updateWorkingDays(List<String> workingDays) async {
    final response = await _dio.post('/scorecard/working-days', data: {
      'working_days': workingDays,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data?['message'] ?? 'Failed to update working days');
    }
  }
}
