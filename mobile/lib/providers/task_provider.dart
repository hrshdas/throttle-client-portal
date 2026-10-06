import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedOrgId;

  List<TaskModel> get allTasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedOrgId => _selectedOrgId;

  List<TaskModel> get todayTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get upcomingTasks =>
      _tasks.where((t) => t.status == 'TODO' || t.needsReview).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks({String? organizationId}) async {
    if (organizationId != null) {
      _selectedOrgId = organizationId;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await TaskService.getTasks(organizationId: _selectedOrgId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOrganization(String? orgId) {
    _selectedOrgId = orgId;
    loadTasks(organizationId: orgId);
  }

  Future<bool> createTask({
    required String title,
    String? description,
    String? organizationId,
    bool requiresClientApproval = true,
    String priority = 'MEDIUM',
  }) async {
    try {
      final newTask = await TaskService.createTask(
        title: title,
        description: description,
        organizationId: organizationId,
        requiresClientApproval: requiresClientApproval,
        priority: priority,
      );
      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveTask(String id, {String? comment}) async {
    try {
      final updated = await TaskService.approveTask(id, comment: comment);
      _updateTaskInList(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestChanges(String id, {required String comment}) async {
    try {
      final updated = await TaskService.requestChanges(id, comment: comment);
      _updateTaskInList(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment(String id, String message) async {
    try {
      await TaskService.addComment(id, message);
      final reloaded = await TaskService.getTaskDetail(id);
      _updateTaskInList(reloaded);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateTaskInList(TaskModel updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
    } else {
      _tasks.insert(0, updated);
    }
    notifyListeners();
  }

  void toggleTask(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final t = _tasks[idx];
    if (t.needsReview) {
      approveTask(id);
    }
  }
}
