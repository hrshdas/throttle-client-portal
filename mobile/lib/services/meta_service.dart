import '../core/api/api_client.dart';
import '../models/meta_connection_model.dart';

class MetaService {
  static Future<MetaConnectionModel?> getMetaConnection() async {
    try {
      final res = await ApiClient.get('/meta/connection');
      if (res != null && res is Map<String, dynamic>) {
        return MetaConnectionModel.fromJson(res);
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<String> startConnect() async {
    final res = await ApiClient.post('/meta/connect/start');
    final data = res as Map<String, dynamic>;
    return data['auth_url'] as String? ?? '';
  }

  static Future<List<Map<String, dynamic>>> getAdAccounts() async {
    final res = await ApiClient.get('/meta/ad-accounts');
    if (res != null && res is List) {
      return List<Map<String, dynamic>>.from(res.map((e) => Map<String, dynamic>.from(e as Map)));
    }
    return [];
  }

  static Future<MetaConnectionModel> selectAdAccount(String adAccountId) async {
    final res = await ApiClient.post('/meta/select-ad-account', body: {'ad_account_id': adAccountId});
    return MetaConnectionModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<MetaConnectionModel> triggerSync() async {
    final res = await ApiClient.post('/meta/sync');
    return MetaConnectionModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> disconnect() async {
    await ApiClient.post('/meta/disconnect');
  }
}
