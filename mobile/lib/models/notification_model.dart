class NotificationModel {
  final String id;
  final String organizationId;
  final String recipientUserId;
  final String type;
  final String title;
  final String message;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.organizationId,
    required this.recipientUserId,
    required this.type,
    required this.title,
    required this.message,
    this.entityType,
    this.entityId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      recipientUserId: json['recipient_user_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
