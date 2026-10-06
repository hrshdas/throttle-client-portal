import '../core/api/api_client.dart';
import '../models/chat_model.dart';

class ChatService {
  static Future<List<dynamic>> getConversations() async {
    final res = await ApiClient.get('/conversations');
    return res as List<dynamic>;
  }

  static Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final res = await ApiClient.get('/conversations/$conversationId/messages');
    final list = res as List<dynamic>;
    return list.map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<ChatMessageModel> sendMessage(String conversationId, String message) async {
    final res = await ApiClient.post(
      '/conversations/$conversationId/messages',
      body: {'message': message},
    );
    return ChatMessageModel.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> markAsRead(String conversationId) async {
    await ApiClient.post('/conversations/$conversationId/read', body: {});
  }
}
