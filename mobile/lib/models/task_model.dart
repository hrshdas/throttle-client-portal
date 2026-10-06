class TaskCommentModel {
  final String id;
  final String taskId;
  final String organizationId;
  final String userId;
  final String userName;
  final String userRole;
  final String? userAvatarUrl;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;

  TaskCommentModel({
    required this.id,
    required this.taskId,
    required this.organizationId,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.userAvatarUrl,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    return TaskCommentModel(
      id: json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Team Member',
      userRole: json['user_role'] ?? 'CLIENT',
      userAvatarUrl: json['user_avatar_url'],
      message: json['message'] ?? '',
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class TaskApprovalHistoryModel {
  final String id;
  final String taskId;
  final String organizationId;
  final String userId;
  final String userName;
  final String action;
  final String? comment;
  final DateTime createdAt;

  TaskApprovalHistoryModel({
    required this.id,
    required this.taskId,
    required this.organizationId,
    required this.userId,
    required this.userName,
    required this.action,
    this.comment,
    required this.createdAt,
  });

  factory TaskApprovalHistoryModel.fromJson(Map<String, dynamic> json) {
    return TaskApprovalHistoryModel(
      id: json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'User',
      action: json['action'] ?? '',
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class TaskModel {
  final String id;
  final String organizationId;
  final String? projectId;
  final String? projectName;
  final String title;
  final String? description;
  final String status;
  final String humanStatus;
  final String priority;
  final String? assignedToUserId;
  final String? assignedToUserName;
  final String? createdByUserId;
  final String? createdByUserName;
  final DateTime? dueDate;
  final bool requiresClientApproval;
  final String approvalStatus;
  final String humanApprovalStatus;
  final DateTime? completedAt;
  final DateTime createdAt;
  final List<TaskCommentModel> comments;
  final List<TaskApprovalHistoryModel> approvalHistory;

  TaskModel({
    required this.id,
    required this.organizationId,
    this.projectId,
    this.projectName,
    required this.title,
    this.description,
    required this.status,
    required this.humanStatus,
    required this.priority,
    this.assignedToUserId,
    this.assignedToUserName,
    this.createdByUserId,
    this.createdByUserName,
    this.dueDate,
    required this.requiresClientApproval,
    required this.approvalStatus,
    required this.humanApprovalStatus,
    this.completedAt,
    required this.createdAt,
    this.comments = const [],
    this.approvalHistory = const [],
  });

  bool get isCompleted => status == 'COMPLETED' || approvalStatus == 'APPROVED';
  bool get needsReview => requiresClientApproval && approvalStatus != 'APPROVED';
  bool get hasChangesRequested => approvalStatus == 'CHANGES_REQUESTED';

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      projectId: json['project_id'],
      projectName: json['project_name'],
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'TODO',
      humanStatus: json['human_status'] ?? json['status'] ?? 'Upcoming',
      priority: json['priority'] ?? 'MEDIUM',
      assignedToUserId: json['assigned_to_user_id'],
      assignedToUserName: json['assigned_to_user_name'],
      createdByUserId: json['created_by_user_id'],
      createdByUserName: json['created_by_user_name'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      requiresClientApproval: json['requires_client_approval'] ?? false,
      approvalStatus: json['approval_status'] ?? 'NOT_REQUIRED',
      humanApprovalStatus: json['human_approval_status'] ?? '',
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      comments: (json['comments'] as List? ?? [])
          .map((c) => TaskCommentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      approvalHistory: (json['approval_history'] as List? ?? [])
          .map((h) => TaskApprovalHistoryModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}
