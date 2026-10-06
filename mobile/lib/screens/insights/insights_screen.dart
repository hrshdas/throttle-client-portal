import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/analytics_provider.dart';
import '../../models/analytics_model.dart';
import '../../widgets/glass_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.triggerSync();
              },
              color: Colors.black,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.screenPadding,
                      24,
                      AppConstants.screenPadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(provider),
                          const SizedBox(height: 12),
                          _buildConnectionBanner(provider),
                          const SizedBox(height: 16),
                          _buildRangeSelector(provider),
                          const SizedBox(height: 20),
                          if (provider.isLoading && provider.overview == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              ),
                            )
                          else ...[
                            _buildTopMetricsRow(provider.overview),
                            const SizedBox(height: AppConstants.sectionGap),
                            _buildRoasChart(provider),
                            const SizedBox(height: AppConstants.sectionGap),
                            _buildDetailMetrics(provider.overview),
                            const SizedBox(height: AppConstants.sectionGap),
                            _buildCampaignsList(provider.campaigns),
                            const SizedBox(height: 100),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AnalyticsProvider provider) {
    final conn = provider.connection;
    final isConnected = conn != null && conn.isConnected;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real Meta Marketing API Data',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showMetaOptionsMenu(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFF34C759).withOpacity(0.12)
                  : const Color(0xFFFF9500).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isConnected
                    ? const Color(0xFF34C759).withOpacity(0.3)
                    : const Color(0xFFFF9500).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected
                      ? (conn.adAccountName ?? 'Meta Connected')
                      : 'Disconnected',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? const Color(0xFF248A3D) : const Color(0xFFC97500),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: isConnected ? const Color(0xFF248A3D) : const Color(0xFFC97500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionBanner(AnalyticsProvider provider) {
    if (provider.isMetaConnected) return const SizedBox();

    final isPending = provider.isPendingAccountSelection;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign, color: Color(0xFF1877F2), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? 'Select Meta Ad Account' : 'Connect Meta Ad Account',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPending
                      ? 'Choose an account to track real performance'
                      : 'Authorize Throttle to pull live campaign metrics',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (isPending) {
                _showAdAccountPicker(context, provider);
              } else {
                provider.startMetaOAuth();
              }
            },
            child: Text(
              isPending ? 'Select' : 'Connect',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showMetaOptionsMenu(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isConnected = provider.isMetaConnected;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meta Ads Integration',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.link, color: Color(0xFF1877F2)),
                  title: Text('Connect / Reauthorize Meta', style: GoogleFonts.inter(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    provider.startMetaOAuth();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.black),
                  title: Text('Select Ad Account', style: GoogleFonts.inter(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    _showAdAccountPicker(context, provider);
                  },
                ),
                if (isConnected) ...[
                  ListTile(
                    leading: const Icon(Icons.sync, color: Colors.green),
                    title: Text('Trigger Manual Sync', style: GoogleFonts.inter(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      provider.triggerSync();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.link_off, color: Colors.red),
                    title: Text('Disconnect Meta Account', style: GoogleFonts.inter(fontSize: 14, color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      provider.disconnectMeta();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdAccountPicker(BuildContext context, AnalyticsProvider provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    final accounts = await provider.fetchAdAccounts();
    if (!context.mounted) return;
    Navigator.pop(context); // Close loading indicator

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Meta Ad Account',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: accounts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No accessible Meta Ad Accounts found. Please make sure your Meta user has access to an ad account.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.secondaryText),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final acc = accounts[idx];
                      return ListTile(
                        title: Text(
                          acc['name'] ?? acc['id'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          'ID: ${acc['id']} • Currency: ${acc['currency'] ?? 'USD'}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          Navigator.pop(context);
                          provider.selectAdAccount(acc['id']);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.secondaryText)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRangeSelector(AnalyticsProvider provider) {
    final ranges = [
      {'key': '7d', 'label': '7 Days'},
      {'key': '30d', 'label': '30 Days'},
      {'key': '90d', 'label': '90 Days'},
    ];

    return Row(
      children: ranges.map((r) {
        final isSelected = provider.selectedRange == r['key'];
        return GestureDetector(
          onTap: () => provider.setRange(r['key']!),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              r['label']!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.secondaryText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopMetricsRow(AnalyticsOverviewModel? overview) {
    final roasStr = overview?.roas != null ? overview!.roas!.toStringAsFixed(2) : '—';
    final cpmStr = overview?.cpm != null ? '₹${overview!.cpm!.toStringAsFixed(2)}' : '—';
    final ctrStr = overview?.ctr != null ? '${overview!.ctr!.toStringAsFixed(1)}%' : '—';
    final cpcStr = overview?.cpc != null ? '₹${overview!.cpc!.toStringAsFixed(2)}' : '—';
    final cplStr = overview?.cpl != null ? '₹${overview!.cpl!.toStringAsFixed(2)}' : '—';

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROAS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tertiaryText,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  roasStr,
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Return on Ad Spend',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CPM',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tertiaryText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cpmStr,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CTR',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tertiaryText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ctrStr,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CPC',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tertiaryText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cpcStr,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CPL',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.tertiaryText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cplStr,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoasChart(AnalyticsProvider provider) {
    final points = provider.timeSeries;

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    double minY = 0.0;
    double maxY = 10.0;
    if (spots.isNotEmpty) {
      final values = spots.map((s) => s.y).toList();
      final minV = values.reduce((a, b) => a < b ? a : b);
      final maxV = values.reduce((a, b) => a > b ? a : b);
      minY = (minV * 0.85).floorToDouble();
      maxY = (maxV * 1.15).ceilToDouble();
      if (maxY == minY) maxY += 5.0;
    }

    final metricLabel = provider.selectedChartMetric.toUpperCase();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$metricLabel Trend',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                  letterSpacing: 0.2,
                ),
              ),
              DropdownButton<String>(
                value: provider.selectedChartMetric,
                underline: const SizedBox(),
                isDense: true,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText,
                ),
                onChanged: (val) {
                  if (val != null) provider.setChartMetric(val);
                },
                items: const [
                  DropdownMenuItem(value: 'roas', child: Text('ROAS')),
                  DropdownMenuItem(value: 'spend', child: Text('Spend')),
                  DropdownMenuItem(value: 'cpm', child: Text('CPM')),
                  DropdownMenuItem(value: 'ctr', child: Text('CTR')),
                  DropdownMenuItem(value: 'cpl', child: Text('CPL')),
                  DropdownMenuItem(value: 'leads', child: Text('Leads')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (spots.isEmpty)
            SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'No historical trend data available',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.tertiaryText),
                ),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < points.length && idx % (points.length ~/ 4 + 1) == 0) {
                            final rawDate = points[idx].date;
                            final dateParts = rawDate.split('-');
                            final shortDate = dateParts.length >= 3 ? '${dateParts[1]}/${dateParts[2]}' : rawDate;
                            return Text(
                              shortDate,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppTheme.tertiaryText,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 24,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppTheme.primaryText,
                      barWidth: 2.0,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: points.length <= 15,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: AppTheme.primaryText,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryText.withOpacity(0.08),
                            AppTheme.primaryText.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  minY: minY,
                  maxY: maxY,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailMetrics(AnalyticsOverviewModel? overview) {
    final spendStr = overview != null ? '₹${overview.spend.toStringAsFixed(2)}' : '—';
    final impStr = overview != null ? _formatLarge(overview.impressions) : '—';
    final reachStr = overview != null ? _formatLarge(overview.reach) : '—';
    final clicksStr = overview != null ? _formatLarge(overview.clicks) : '—';
    final leadsStr = overview != null ? overview.leads.toString() : '—';
    final convStr = overview != null ? overview.conversions.toString() : '—';

    final metrics = [
      _MetricRow('Total Spend', spendStr),
      _MetricRow('Impressions', impStr),
      _MetricRow('Reach', reachStr),
      _MetricRow('Clicks', clicksStr),
      _MetricRow('Leads Generated', leadsStr),
      _MetricRow('Conversions', convStr),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT OVERVIEW METRICS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.tertiaryText,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...metrics.asMap().entries.map((e) {
            return Column(
              children: [
                if (e.key > 0)
                  Divider(
                    height: 1,
                    color: Colors.black.withOpacity(0.05),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.value.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      Text(
                        e.value.value,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCampaignsList(List<CampaignAnalyticsModel> campaigns) {
    if (campaigns.isEmpty) return const SizedBox();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE CAMPAIGNS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.tertiaryText,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...campaigns.asMap().entries.map((e) {
            final c = e.value;
            return Column(
              children: [
                if (e.key > 0)
                  Divider(
                    height: 1,
                    color: Colors.black.withOpacity(0.05),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.status == 'ACTIVE'
                                  ? const Color(0xFF34C759).withOpacity(0.12)
                                  : Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              c.status,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: c.status == 'ACTIVE'
                                    ? const Color(0xFF248A3D)
                                    : AppTheme.tertiaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spend: ₹${c.spend.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText),
                          ),
                          Text(
                            'ROAS: ${c.roas != null ? c.roas!.toStringAsFixed(2) : '—'}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText),
                          ),
                          Text(
                            'Leads: ${c.leads}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatLarge(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _MetricRow {
  final String label;
  final String value;
  const _MetricRow(this.label, this.value);
}
