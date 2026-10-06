import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/task_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class CreateTaskModal extends StatefulWidget {
  final String? initialOrgId;

  const CreateTaskModal({super.key, this.initialOrgId});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _requiresApproval = true;
  String _priority = 'MEDIUM';
  String? _selectedOrgId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedOrgId = widget.initialOrgId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final tp = Provider.of<TaskProvider>(context, listen: false);
    final success = await tp.createTask(
      title: title,
      description: _descController.text.trim(),
      organizationId: _selectedOrgId,
      requiresClientApproval: _requiresApproval,
      priority: _priority,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "$title" created successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final isAdmin = authProvider.userRole == 'THROTTLE_ADMIN' || authProvider.userRole == 'THROTTLE_STAFF';

    // Get unique client orgs from Admin's conversations
    final convs = chatProvider.conversations;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.90,
        expand: false,
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

                // Title Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Task',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Admin Client Selector Dropdown
                      if (isAdmin && convs.isNotEmpty) ...[
                        Text(
                          'CLIENT ORGANIZATION',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.tertiaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4E4E8), width: 0.8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedOrgId,
                              isExpanded: true,
                              hint: const Text('Select Client Organization', style: TextStyle(fontSize: 14)),
                              items: convs.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.organizationId,
                                  child: Text(
                                    '${c.partnerName} (${c.organizationName ?? 'Org'})',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedOrgId = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Task Title
                      Text(
                        'TASK TITLE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'e.g. Review Meta Ad Creatives',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'DESCRIPTION',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add task requirements or details...',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F9),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority Selection
                      Text(
                        'PRIORITY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['LOW', 'MEDIUM', 'HIGH'].map((p) {
                          final selected = _priority == p;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _priority = p),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? AppTheme.primaryText : const Color(0xFFF7F7F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    p,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.white : AppTheme.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Requires Approval Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Requires Client Review & Approval',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Client will be notified to approve or request changes.',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _requiresApproval,
                              activeColor: const Color(0xFF34C759),
                              onChanged: (val) => setState(() => _requiresApproval = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text(
                            'Create Task',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
