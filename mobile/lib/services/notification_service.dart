import '../core/api/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    final res = await ApiClient.get('/notifications');
    final list = res as List<dynamic>;
    return list.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<void> markRead(String notificationId) async {
    await ApiClient.post('/notifications/$notificationId/read');
  }

  static Future<void> markAllRead() async {
    await ApiClient.post('/notifications/read-all');
  }
}
