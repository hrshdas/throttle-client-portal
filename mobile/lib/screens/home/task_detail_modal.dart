import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/glass_card.dart';

import '../../providers/auth_provider.dart';

class TaskDetailModal extends StatefulWidget {
  final TaskModel task;

  const TaskDetailModal({super.key, required this.task});

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showRequestChangesDialog(BuildContext context) {
    final changesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Request Changes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please describe the changes required:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: changesController,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Please make the headline on Creative 4 slightly larger.',
                filled: true,
                fillColor: const Color(0xFFF7F7F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final comment = changesController.text.trim();
              if (comment.isEmpty) return;
              Navigator.pop(ctx);

              final tp = Provider.of<TaskProvider>(context, listen: false);
              final success = await tp.requestChanges(widget.task.id, comment: comment);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Changes requested successfully.'),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();

    final tp = Provider.of<TaskProvider>(context, listen: false);
    await tp.addComment(widget.task.id, text);
  }

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userRole == 'THROTTLE_ADMIN' || authProvider.userRole == 'THROTTLE_STAFF';

    // Get latest task state from provider if available
    final currentTask = tp.allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Task Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusBg(currentTask),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentTask.humanApprovalStatus.isNotEmpty
                                ? currentTask.humanApprovalStatus
                                : currentTask.humanStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusFg(currentTask),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (currentTask.projectName != null)
                          Text(
                            currentTask.projectName!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      currentTask.title,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (currentTask.description != null) ...[
                      Text(
                        currentTask.description!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Info Metadata Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _MetaRow('Assigned To', currentTask.assignedToUserName ?? 'Team Member'),
                          _MetaRow('Created By', currentTask.createdByUserName ?? 'Throttle Admin'),
                          if (currentTask.dueDate != null)
                            _MetaRow('Due Date', DateFormat('dd MMMM yyyy').format(currentTask.dueDate!)),
                          _MetaRow('Priority', currentTask.priority),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Review & Approval Action Buttons (ONLY FOR CLIENT USERS)
                    if (currentTask.needsReview) ...[
                      if (!isAdmin) ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: currentTask.hasChangesRequested
                                ? Colors.orange.shade50
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: currentTask.hasChangesRequested
                                  ? Colors.orange.shade200
                                  : Colors.amber.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    currentTask.hasChangesRequested
                                        ? Icons.history_rounded
                                        : Icons.rate_review_outlined,
                                    color: currentTask.hasChangesRequested
                                        ? Colors.orange.shade900
                                        : Colors.amber.shade900,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentTask.hasChangesRequested
                                        ? 'Changes Requested'
                                        : 'Ready for Your Review',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: currentTask.hasChangesRequested
                                          ? Colors.orange.shade900
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentTask.hasChangesRequested
                                    ? 'You requested changes. You can approve this task at any time once you are satisfied.'
                                    : 'Please review the work completed and approve or request changes.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: currentTask.hasChangesRequested
                                      ? Colors.orange.shade900
                                      : Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showRequestChangesDialog(context),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: const BorderSide(color: Colors.black54),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(
                                        currentTask.hasChangesRequested
                                            ? 'Update Request'
                                            : 'Request Changes',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final success = await tp.approveTask(currentTask.id);
                                        if (success && context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Task Approved!'),
                                              backgroundColor: Colors.green.shade700,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // For Admin: Informational banner only (No approval / change buttons)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.hourglass_top_rounded, color: Colors.blue.shade800, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentTask.hasChangesRequested
                                          ? 'Client Requested Changes'
                                          : 'Awaiting Client Review & Approval',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currentTask.hasChangesRequested
                                          ? 'The client requested changes on this task. Awaiting client final approval.'
                                          : 'This task is pending final review and approval by the client.',
                                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                    // Approval History Timeline
                    if (currentTask.approvalHistory.isNotEmpty) ...[
                      Text(
                        'APPROVAL HISTORY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppTheme.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...currentTask.approvalHistory.map(
                        (h) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE4E4E8), width: 0.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                h.action == 'APPROVED' ? Icons.check_circle_outline : Icons.replay_rounded,
                                size: 18,
                                color: h.action == 'APPROVED' ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${h.userName} — ${h.action == 'APPROVED' ? 'Approved' : 'Changes requested'}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    if (h.comment != null) ...[
                                      const SizedBox(height: 2),
                                      Text(h.comment!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM, hh:mm a').format(h.createdAt),
                                      style: const TextStyle(fontSize: 10, color: Colors.black45),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Task Comments Feed
                    Text(
                      'COMMENTS & DISCUSSION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.tertiaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (currentTask.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No comments yet. Start the conversation below.', style: TextStyle(fontSize: 13, color: Colors.black45)),
                      )
                    else
                      ...currentTask.comments.map(
                        (c) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: c.userRole == 'THROTTLE_ADMIN' ? Colors.black.withOpacity(0.04) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE4E4E8), width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c.userName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: c.userRole == 'THROTTLE_ADMIN' ? Colors.black : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      c.userRole == 'THROTTLE_ADMIN' ? 'AGENCY' : 'CLIENT',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: c.userRole == 'THROTTLE_ADMIN' ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('hh:mm a').format(c.createdAt),
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(c.message, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Comment Input Field at Bottom
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE4E4E8), width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendComment,
                      icon: const Icon(Icons.send_rounded, color: Colors.black),
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

  Color _getStatusBg(TaskModel t) {
    if (t.approvalStatus == 'APPROVED') return Colors.green.shade100;
    if (t.approvalStatus == 'CHANGES_REQUESTED') return Colors.orange.shade100;
    if (t.needsReview) return Colors.amber.shade100;
    return Colors.grey.shade200;
  }

  Color _getStatusFg(TaskModel t) {
    if (t.approvalStatus == 'APPROVED') return Colors.green.shade900;
    if (t.approvalStatus == 'CHANGES_REQUESTED') return Colors.orange.shade900;
    if (t.needsReview) return Colors.amber.shade900;
    return Colors.black87;
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}
