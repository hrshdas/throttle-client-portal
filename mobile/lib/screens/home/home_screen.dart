import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../models/insights_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/api/mock_data_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/task_item.dart';
import 'task_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final DashboardStats _stats = MockDataService.getDashboardStats();

  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openTaskDetail(BuildContext ctx, task) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailModal(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenPadding,
                  20,
                  AppConstants.screenPadding,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildInsightsCard(),
                      const SizedBox(height: 14),
                      _buildStatsRow(),
                      const SizedBox(height: 14),
                      _buildTasksCard(),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final greeting = AppDateUtils.getGreeting();
    final dateStr = AppDateUtils.getFormattedDate();
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName;

    return ClipRect(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$greeting ',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.primaryText,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
                        text: '$userName.',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryText,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateStr • ${authProvider.orgName}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(flex: 0, child: _buildSearch()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return GestureDetector(
      onTap: () {
        setState(() => _searchExpanded = !_searchExpanded);
        if (!_searchExpanded) _searchController.clear();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        width: _searchExpanded ? 160 : 90,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.searchAccent, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.searchAccent.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),
            Icon(Icons.search_rounded, size: 15,
                color: AppTheme.tertiaryText),
            const SizedBox(width: 4),
            if (_searchExpanded)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.primaryText),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.tertiaryText),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
            else
              Text(
                'search...',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.tertiaryText),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final overview = provider.overview;
        final roasStr = overview?.roas != null ? overview!.roas!.toStringAsFixed(2) : '—';
        final cpmStr = overview?.cpm != null ? '₹${overview!.cpm!.toStringAsFixed(2)}' : '—';
        final ctrStr = overview?.ctr != null ? '${overview!.ctr!.toStringAsFixed(1)}%' : '—';

        return GlassCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Insights',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.secondaryText,
                      letterSpacing: 0.1,
                    ),
                  ),
                  if (provider.isMetaConnected)
                    Text(
                      '● Meta Connected',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF248A3D),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      value: roasStr,
                      label: 'ROAS',
                    ),
                  ),
                  Expanded(
                    child: MetricCard(
                      value: cpmStr,
                      label: 'CPM',
                    ),
                  ),
                  Expanded(
                    child: MetricCard(
                      value: ctrStr,
                      label: 'CTR',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'VIEWS',
              value: NumberUtils.formatCompact(_stats.views),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StatCard(
              title: 'CONTENT',
              value: NumberUtils.formatCompact(_stats.content),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard() {
    return Consumer<TaskProvider>(
      builder: (context, tp, _) {
        final tasks = tp.todayTasks;
        return GlassCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TASKS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              ...tasks.map(
                (task) => Column(
                  children: [
                    if (task != tasks.first)
                      Divider(height: 1, color: AppTheme.divider),
                    TaskItem(
                      task: task,
                      onTap: () => _openTaskDetail(context, task),
                      onToggle: () => tp.toggleTask(task.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
