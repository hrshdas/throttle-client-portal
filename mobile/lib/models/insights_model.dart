class InsightsModel {
  final double roas;
  final double cpm;
  final double ctr;
  final double cpc;
  final double cpl;
  final double spend;
  final int impressions;
  final int reach;
  final int clicks;
  final int leads;
  final int conversions;

  const InsightsModel({
    required this.roas,
    required this.cpm,
    required this.ctr,
    required this.cpc,
    required this.cpl,
    required this.spend,
    required this.impressions,
    required this.reach,
    required this.clicks,
    required this.leads,
    required this.conversions,
  });
}

class DashboardStats {
  final int views;
  final int content;

  const DashboardStats({
    required this.views,
    required this.content,
  });
}
