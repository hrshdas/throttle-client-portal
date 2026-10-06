import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../models/task_model.dart';

/// A single task list item with a circular status indicator on the right.
class TaskItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.isCompleted;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: isCompleted
                        ? AppTheme.tertiaryText
                        : AppTheme.primaryText,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppTheme.tertiaryText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppTheme.primaryText.withOpacity(0.15)
                        : AppTheme.taskCircle,
                    border: isCompleted
                        ? Border.all(color: AppTheme.primaryText.withOpacity(0.3), width: 1.5)
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.black54)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header for task groups (TODAY, UPCOMING, COMPLETED).
class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.tertiaryText,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
