import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/task_item.dart';
import '../home/task_detail_modal.dart';
import 'create_task_modal.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openAddTask(BuildContext context, String? initialOrgId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateTaskModal(initialOrgId: initialOrgId),
    );
  }

  void _openDetail(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailModal(task: task),
    );
  }

  Widget _buildAdminClientSelector(TaskProvider tp, ChatProvider chatProvider) {
    final selectedOrgId = tp.selectedOrgId;
    final convs = chatProvider.conversations;

    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // All Clients Chip
          GestureDetector(
            onTap: () => tp.selectOrganization(null),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selectedOrgId == null ? AppTheme.primaryText : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedOrgId == null ? AppTheme.primaryText : const Color(0xFFE4E4E8),
                ),
              ),
              child: Text(
                'All Clients',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selectedOrgId == null ? Colors.white : AppTheme.primaryText,
                ),
              ),
            ),
          ),
          ...convs.map((conv) {
            final isSelected = selectedOrgId == conv.organizationId;
            final label = '${conv.partnerName} (${conv.organizationName ?? 'Client'})';
            return GestureDetector(
              onTap: () => tp.selectOrganization(conv.organizationId),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryText : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryText : const Color(0xFFE4E4E8),
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.primaryText,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final isAdmin = authProvider.userRole == 'THROTTLE_ADMIN' || authProvider.userRole == 'THROTTLE_STAFF';

    return FadeTransition(
      opacity: _fadeAnim,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPadding,
                16,
                AppConstants.screenPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Consumer<TaskProvider>(
                  builder: (context, tp, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tasks',
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryText,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAdmin
                                      ? 'Client 1-on-1 Task Manager'
                                      : 'Your Private Tasks • 1-on-1 Workspace',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF34C759),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _openAddTask(context, tp.selectedOrgId),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryText,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Admin Client Selector Filter Bar
                        if (isAdmin) _buildAdminClientSelector(tp, chatProvider),

                        if (!isAdmin) const SizedBox(height: 16),

                        if (tp.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            ),
                          )
                        else if (tp.allTasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No tasks found for this client workspace.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          if (tp.todayTasks.isNotEmpty) ...[
                            const SectionHeader(title: 'TODAY'),
                            const SizedBox(height: 8),
                            GlassCard(
                              child: Column(
                                children: tp.todayTasks.asMap().entries.map((e) {
                                  return Column(
                                    children: [
                                      if (e.key > 0)
                                        Divider(
                                          height: 1,
                                          color: Colors.black.withValues(alpha: 0.05),
                                        ),
                                      TaskItem(
                                        task: e.value,
                                        onTap: () =>
                                            _openDetail(context, e.value),
                                        onToggle: () =>
                                            tp.toggleTask(e.value.id),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: AppConstants.sectionGap),
                          ],
                          if (tp.upcomingTasks.isNotEmpty) ...[
                            const SectionHeader(title: 'UPCOMING'),
                            const SizedBox(height: 8),
                            GlassCard(
                              child: Column(
                                children: tp.upcomingTasks.asMap().entries.map((e) {
                                  return Column(
                                    children: [
                                      if (e.key > 0)
                                        Divider(
                                          height: 1,
                                          color: Colors.black.withValues(alpha: 0.05),
                                        ),
                                      TaskItem(
                                        task: e.value,
                                        onTap: () =>
                                            _openDetail(context, e.value),
                                        onToggle: () =>
                                            tp.toggleTask(e.value.id),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: AppConstants.sectionGap),
                          ],
                          if (tp.completedTasks.isNotEmpty) ...[
                            const SectionHeader(title: 'COMPLETED'),
                            const SizedBox(height: 8),
                            GlassCard(
                              child: Column(
                                children: tp.completedTasks.asMap().entries.map((e) {
                                  return Column(
                                    children: [
                                      if (e.key > 0)
                                        Divider(
                                          height: 1,
                                          color: Colors.black.withValues(alpha: 0.05),
                                        ),
                                      TaskItem(
                                        task: e.value,
                                        onTap: () =>
                                            _openDetail(context, e.value),
                                        onToggle: () =>
                                            tp.toggleTask(e.value.id),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
