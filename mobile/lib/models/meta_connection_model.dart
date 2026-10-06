class MetaConnectionModel {
  final String id;
  final String organizationId;
  final String? metaUserId;
  final String? businessId;
  final String? adAccountId;
  final String? adAccountName;
  final String status;
  final String? errorMessage;
  final DateTime? lastSyncedAt;

  MetaConnectionModel({
    required this.id,
    required this.organizationId,
    this.metaUserId,
    this.businessId,
    this.adAccountId,
    this.adAccountName,
    required this.status,
    this.errorMessage,
    this.lastSyncedAt,
  });

  bool get isConnected => status == 'CONNECTED' || status == 'SYNCED' || status == 'SYNCING';

  factory MetaConnectionModel.fromJson(Map<String, dynamic> json) {
    return MetaConnectionModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      metaUserId: json['meta_user_id'] as String?,
      businessId: json['business_id'] as String?,
      adAccountId: json['ad_account_id'] as String?,
      adAccountName: json['ad_account_name'] as String?,
      status: json['status'] as String? ?? 'DISCONNECTED',
      errorMessage: json['error_message'] as String?,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.tryParse(json['last_synced_at'] as String)
          : null,
    );
  }
}
