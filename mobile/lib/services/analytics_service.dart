import '../core/api/api_client.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  static Future<AnalyticsOverviewModel> getOverview({String range = '30d'}) async {
    final res = await ApiClient.get('/analytics/overview?range=$range');
    return AnalyticsOverviewModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<List<TimeSeriesPointModel>> getTimeSeries({
    String metric = 'roas',
    String range = '30d',
  }) async {
    final res = await ApiClient.get('/analytics/timeseries?metric=$metric&range=$range');
    final list = res as List<dynamic>;
    return list.map((item) => TimeSeriesPointModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<CampaignAnalyticsModel>> getCampaigns({String range = '30d'}) async {
    final res = await ApiClient.get('/analytics/campaigns?range=$range');
    final list = res as List<dynamic>;
    return list.map((item) => CampaignAnalyticsModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
