import '../core/api/api_client.dart';
import '../models/task_model.dart';

class TaskService {
  static Future<List<TaskModel>> getTasks({String? organizationId}) async {
    final path = (organizationId != null && organizationId.isNotEmpty)
        ? '/tasks?organization_id=$organizationId'
        : '/tasks';
    final res = await ApiClient.get(path);
    final list = res as List<dynamic>;
    return list.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<TaskModel> createTask({
    required String title,
    String? description,
    String? organizationId,
    bool requiresClientApproval = true,
    String priority = 'MEDIUM',
  }) async {
    final body = <String, dynamic>{
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      if (organizationId != null && organizationId.isNotEmpty) 'organization_id': organizationId,
      'requires_client_approval': requiresClientApproval,
      'priority': priority,
    };
    final res = await ApiClient.post('/tasks', body: body);
    return TaskModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<TaskModel> getTaskDetail(String taskId) async {
    final res = await ApiClient.get('/tasks/$taskId');
    return TaskModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<TaskModel> approveTask(String taskId, {String? comment}) async {
    final res = await ApiClient.post(
      '/tasks/$taskId/approve',
      body: {'comment': comment},
    );
    return TaskModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<TaskModel> requestChanges(String taskId, {required String comment}) async {
    final res = await ApiClient.post(
      '/tasks/$taskId/request-changes',
      body: {'comment': comment},
    );
    return TaskModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<TaskCommentModel> addComment(String taskId, String message) async {
    final res = await ApiClient.post(
      '/tasks/$taskId/comments',
      body: {'message': message},
    );
    return TaskCommentModel.fromJson(res as Map<String, dynamic>);
  }
}
