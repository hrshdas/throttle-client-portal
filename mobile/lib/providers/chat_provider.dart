import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  ConversationModel? _activeConversation;
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ConversationModel> get conversations => List.unmodifiable(_conversations);
  ConversationModel? get activeConversation => _activeConversation;
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get conversationId => _activeConversation?.id;

  void clear() {
    _conversations = [];
    _activeConversation = null;
    _messages = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void selectConversation(ConversationModel conv) async {
    _activeConversation = conv;
    _messages = [];

    // Instant local unread count clear
    final idx = _conversations.indexWhere((c) => c.id == conv.id);
    if (idx != -1) {
      final old = _conversations[idx];
      _conversations[idx] = ConversationModel(
        id: old.id,
        organizationId: old.organizationId,
        organizationName: old.organizationName,
        title: old.title,
        isDirect: old.isDirect,
        isEncrypted: old.isEncrypted,
        partnerUserId: old.partnerUserId,
        partnerName: old.partnerName,
        partnerAvatarUrl: old.partnerAvatarUrl,
        partnerRole: old.partnerRole,
        createdAt: old.createdAt,
        updatedAt: old.updatedAt,
        unreadCount: 0,
        lastMessage: old.lastMessage,
      );
    }
    notifyListeners();

    // Call backend mark read
    ChatService.markAsRead(conv.id);
    await loadMessagesForActive();
  }

  void clearActiveConversation() {
    _activeConversation = null;
    _messages = [];
    notifyListeners();
  }

  Future<void> loadChat({bool isAdmin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawConvs = await ChatService.getConversations();
      _conversations = rawConvs
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Ensure conversations are sorted by last message timestamp descending
      _conversations.sort((a, b) {
        final dtA = a.lastMessage?.createdAt ?? a.updatedAt;
        final dtB = b.lastMessage?.createdAt ?? b.updatedAt;
        return dtB.compareTo(dtA);
      });

      if (_conversations.isNotEmpty) {
        if (!isAdmin) {
          // Client user: automatically select their 1-on-1 direct conversation
          _activeConversation = _conversations[0];
          await loadMessagesForActive();
        } else if (_activeConversation != null) {
          // Admin user: preserve selected conversation if active
          final found = _conversations.firstWhere(
            (c) => c.id == _activeConversation!.id,
            orElse: () => _conversations[0],
          );
          _activeConversation = found;
          await loadMessagesForActive();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessagesForActive() async {
    if (_activeConversation == null) return;
    try {
      _messages = await ChatService.getMessages(_activeConversation!.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _activeConversation == null) return;
    try {
      final newMsg = await ChatService.sendMessage(_activeConversation!.id, text.trim());
      _messages.add(newMsg);

      // Instantly move the texted conversation to top of list
      final idx = _conversations.indexWhere((c) => c.id == _activeConversation!.id);
      if (idx != -1) {
        final target = _conversations.removeAt(idx);
        final updatedConv = ConversationModel(
          id: target.id,
          organizationId: target.organizationId,
          organizationName: target.organizationName,
          title: target.title,
          isDirect: target.isDirect,
          isEncrypted: target.isEncrypted,
          partnerUserId: target.partnerUserId,
          partnerName: target.partnerName,
          partnerAvatarUrl: target.partnerAvatarUrl,
          partnerRole: target.partnerRole,
          createdAt: target.createdAt,
          updatedAt: newMsg.createdAt,
          unreadCount: 0,
          lastMessage: newMsg,
        );
        _conversations.insert(0, updatedConv);
        _activeConversation = updatedConv;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
