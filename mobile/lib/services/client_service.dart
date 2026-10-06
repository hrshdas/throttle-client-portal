import '../core/api/api_client.dart';

class ClientService {
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiClient.get('/client/me');
    return res as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getProjects() async {
    final res = await ApiClient.get('/client/projects');
    return res as List<dynamic>;
  }

  static Future<List<dynamic>> getTasks() async {
    final res = await ApiClient.get('/client/tasks');
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    final res = await ApiClient.patch(
      '/client/tasks/$taskId',
      body: {'status': status},
    );
    return res as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMessages() async {
    final res = await ApiClient.get('/client/messages');
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> sendMessage(String content) async {
    final res = await ApiClient.post(
      '/client/messages',
      body: {'message': content},
    );
    return res as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getActivities() async {
    final res = await ApiClient.get('/client/activities');
    return res as List<dynamic>;
  }
}
