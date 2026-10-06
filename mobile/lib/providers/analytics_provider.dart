import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meta_connection_model.dart';
import '../models/analytics_model.dart';
import '../services/meta_service.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  MetaConnectionModel? _connection;
  AnalyticsOverviewModel? _overview;
  List<TimeSeriesPointModel> _timeSeries = [];
  List<CampaignAnalyticsModel> _campaigns = [];
  List<Map<String, dynamic>> _adAccounts = [];

  String _selectedRange = '30d';
  String _selectedChartMetric = 'roas';
  bool _isLoading = false;
  String? _errorMessage;

  MetaConnectionModel? get connection => _connection;
  AnalyticsOverviewModel? get overview => _overview;
  List<TimeSeriesPointModel> get timeSeries => _timeSeries;
  List<CampaignAnalyticsModel> get campaigns => _campaigns;
  List<Map<String, dynamic>> get adAccounts => _adAccounts;

  String get selectedRange => _selectedRange;
  String get selectedChartMetric => _selectedChartMetric;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isMetaConnected => _connection?.isConnected ?? false;
  bool get isPendingAccountSelection => _connection?.status == 'PENDING_ACCOUNT_SELECTION';

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final connRes = await MetaService.getMetaConnection();
      _connection = connRes;

      final results = await Future.wait([
        AnalyticsService.getOverview(range: _selectedRange),
        AnalyticsService.getTimeSeries(metric: _selectedChartMetric, range: _selectedRange),
        AnalyticsService.getCampaigns(range: _selectedRange),
      ]);

      _overview = results[0] as AnalyticsOverviewModel;
      _timeSeries = results[1] as List<TimeSeriesPointModel>;
      _campaigns = results[2] as List<CampaignAnalyticsModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startMetaOAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final authUrl = await MetaService.startConnect();
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _errorMessage = 'Could not open Meta authorization page';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchAdAccounts() async {
    try {
      _adAccounts = await MetaService.getAdAccounts();
      notifyListeners();
      return _adAccounts;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> selectAdAccount(String adAccountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _connection = await MetaService.selectAdAccount(adAccountId);
      await fetchAnalytics();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRange(String range) async {
    if (_selectedRange == range) return;
    _selectedRange = range;
    await fetchAnalytics();
  }

  Future<void> setChartMetric(String metric) async {
    if (_selectedChartMetric == metric) return;
    _selectedChartMetric = metric;
    notifyListeners();
    try {
      _timeSeries = await AnalyticsService.getTimeSeries(
        metric: _selectedChartMetric,
        range: _selectedRange,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> triggerSync() async {
    _isLoading = true;
    notifyListeners();
    try {
      _connection = await MetaService.triggerSync();
      await fetchAnalytics();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnectMeta() async {
    _isLoading = true;
    notifyListeners();
    try {
      await MetaService.disconnect();
      _connection = null;
      await fetchAnalytics();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
