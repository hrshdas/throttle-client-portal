class ChatMessageModel {
  final String id;
  final String? conversationId;
  final String organizationId;
  final String senderUserId;
  final String senderName;
  final String? senderAvatarUrl;
  final String senderRole;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? readAt;

  ChatMessageModel({
    required this.id,
    this.conversationId,
    required this.organizationId,
    required this.senderUserId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.senderRole,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
    this.readAt,
  });

  bool get isAgency => senderRole == 'THROTTLE_ADMIN' || senderRole == 'THROTTLE_STAFF';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'],
      organizationId: json['organization_id'] ?? '',
      senderUserId: json['sender_user_id'] ?? '',
      senderName: json['sender_name'] ?? 'Team Member',
      senderAvatarUrl: json['sender_avatar_url'],
      senderRole: json['sender_role'] ?? 'CLIENT',
      message: json['message'] ?? json['content'] ?? '',
      attachmentUrl: json['attachment_url'] ?? json['file_attachment_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']).toLocal() : null,
    );
  }
}

class ConversationModel {
  final String id;
  final String organizationId;
  final String? organizationName;
  final String? title;
  final bool isDirect;
  final bool isEncrypted;
  final String? partnerUserId;
  final String partnerName;
  final String? partnerAvatarUrl;
  final String? partnerRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final ChatMessageModel? lastMessage;

  ConversationModel({
    required this.id,
    required this.organizationId,
    this.organizationName,
    this.title,
    required this.isDirect,
    required this.isEncrypted,
    this.partnerUserId,
    required this.partnerName,
    this.partnerAvatarUrl,
    this.partnerRole,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      organizationName: json['organization_name'],
      title: json['title'],
      isDirect: json['is_direct'] ?? true,
      isEncrypted: json['is_encrypted'] ?? true,
      partnerUserId: json['partner_user_id'],
      partnerName: json['partner_name'] ?? 'Client',
      partnerAvatarUrl: json['partner_avatar_url'],
      partnerRole: json['partner_role'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: json['last_message'] != null
          ? ChatMessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }
}
