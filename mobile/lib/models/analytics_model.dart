class AnalyticsPeriodModel {
  final String start;
  final String end;

  AnalyticsPeriodModel({required this.start, required this.end});

  factory AnalyticsPeriodModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsPeriodModel(
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
    );
  }
}

class AnalyticsOverviewModel {
  final AnalyticsPeriodModel period;
  final double spend;
  final int impressions;
  final int reach;
  final int clicks;
  final int linkClicks;
  final double? ctr;
  final double? cpc;
  final double? cpm;
  final int leads;
  final double? cpl;
  final int conversions;
  final double? conversionValue;
  final double? roas;
  final DateTime? lastSyncedAt;
  final String connectionStatus;

  AnalyticsOverviewModel({
    required this.period,
    required this.spend,
    required this.impressions,
    required this.reach,
    required this.clicks,
    required this.linkClicks,
    this.ctr,
    this.cpc,
    this.cpm,
    required this.leads,
    this.cpl,
    required this.conversions,
    this.conversionValue,
    this.roas,
    this.lastSyncedAt,
    required this.connectionStatus,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      period: json['period'] != null
          ? AnalyticsPeriodModel.fromJson(json['period'] as Map<String, dynamic>)
          : AnalyticsPeriodModel(start: '', end: ''),
      spend: (json['spend'] as num?)?.toDouble() ?? 0.0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      reach: (json['reach'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      linkClicks: (json['link_clicks'] as num?)?.toInt() ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble(),
      cpc: (json['cpc'] as num?)?.toDouble(),
      cpm: (json['cpm'] as num?)?.toDouble(),
      leads: (json['leads'] as num?)?.toInt() ?? 0,
      cpl: (json['cpl'] as num?)?.toDouble(),
      conversions: (json['conversions'] as num?)?.toInt() ?? 0,
      conversionValue: (json['conversion_value'] as num?)?.toDouble(),
      roas: (json['roas'] as num?)?.toDouble(),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.tryParse(json['last_synced_at'] as String)
          : null,
      connectionStatus: json['connection_status'] as String? ?? 'DISCONNECTED',
    );
  }
}

class TimeSeriesPointModel {
  final String date;
  final double value;

  TimeSeriesPointModel({required this.date, required this.value});

  factory TimeSeriesPointModel.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPointModel(
      date: json['date'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CampaignAnalyticsModel {
  final String id;
  final String metaCampaignId;
  final String name;
  final String status;
  final double spend;
  final int impressions;
  final int clicks;
  final double? ctr;
  final double? cpc;
  final double? cpm;
  final int leads;
  final double? cpl;
  final double? roas;

  CampaignAnalyticsModel({
    required this.id,
    required this.metaCampaignId,
    required this.name,
    required this.status,
    required this.spend,
    required this.impressions,
    required this.clicks,
    this.ctr,
    this.cpc,
    this.cpm,
    required this.leads,
    this.cpl,
    this.roas,
  });

  factory CampaignAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CampaignAnalyticsModel(
      id: json['id'] as String? ?? '',
      metaCampaignId: json['meta_campaign_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Campaign',
      status: json['status'] as String? ?? 'ACTIVE',
      spend: (json['spend'] as num?)?.toDouble() ?? 0.0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble(),
      cpc: (json['cpc'] as num?)?.toDouble(),
      cpm: (json['cpm'] as num?)?.toDouble(),
      leads: (json['leads'] as num?)?.toInt() ?? 0,
      cpl: (json['cpl'] as num?)?.toDouble(),
      roas: (json['roas'] as num?)?.toDouble(),
    );
  }
}
