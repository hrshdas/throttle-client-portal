import '../../models/insights_model.dart';

/// Mock data service.
/// Replace the return values here with real Meta API calls when ready.
class MockDataService {
  static InsightsModel getInsights() {
    return const InsightsModel(
      roas: 5.6,
      cpm: 1.8,
      ctr: 4.0,
      cpc: 0.45,
      cpl: 2.1,
      spend: 3200.0,
      impressions: 1800000,
      reach: 1200000,
      clicks: 72000,
      leads: 1524,
      conversions: 432,
    );
  }

  static DashboardStats getDashboardStats() {
    return const DashboardStats(views: 400000, content: 400000);
  }

  static List<Map<String, double>> getWeeklyRoas() {
    return [
      {'value': 4.2},
      {'value': 4.8},
      {'value': 5.1},
      {'value': 4.7},
      {'value': 5.6},
      {'value': 5.3},
      {'value': 5.6},
    ];
  }

  static List<Map<String, double>> getWeeklyCpm() {
    return [
      {'value': 2.1},
      {'value': 1.9},
      {'value': 2.3},
      {'value': 1.7},
      {'value': 1.8},
      {'value': 1.6},
      {'value': 1.8},
    ];
  }
}
