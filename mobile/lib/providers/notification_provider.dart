import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await NotificationService.getNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await NotificationService.markRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        final old = _notifications[idx];
        _notifications[idx] = NotificationModel(
          id: old.id,
          organizationId: old.organizationId,
          recipientUserId: old.recipientUserId,
          type: old.type,
          title: old.title,
          message: old.message,
          entityType: old.entityType,
          entityId: old.entityId,
          isRead: true,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllRead();
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        organizationId: n.organizationId,
        recipientUserId: n.recipientUserId,
        type: n.type,
        title: n.title,
        message: n.message,
        entityType: n.entityType,
        entityId: n.entityId,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (_) {}
  }
}
