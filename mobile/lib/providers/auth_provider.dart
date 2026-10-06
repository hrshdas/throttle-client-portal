import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/client_service.dart';
import '../core/storage/auth_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _organization;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get organization => _organization;

  String get userName => _user?['name'] ?? 'John';
  String get userRole => _user?['role'] ?? 'CLIENT';
  String get orgName => _organization?['name'] ?? 'BLUEFORCE';

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthStorage.getAccessToken();
      if (token != null) {
        final profileData = await ClientService.getProfile();
        _user = profileData['user'] as Map<String, dynamic>?;
        _organization = profileData['organization'] as Map<String, dynamic>?;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.login(email, password);
      final profileData = await ClientService.getProfile();
      _user = profileData['user'] as Map<String, dynamic>?;
      _organization = profileData['organization'] as Map<String, dynamic>?;

      if (_user != null && _organization != null) {
        await AuthStorage.saveUserInfo(
          email: _user!['email'] ?? '',
          name: _user!['name'] ?? '',
          orgName: _organization!['name'] ?? '',
        );
      }

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptInvitation({
    required String token,
    required String name,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.acceptInvitation(token: token, name: name, password: password);
      final profileData = await ClientService.getProfile();
      _user = profileData['user'] as Map<String, dynamic>?;
      _organization = profileData['organization'] as Map<String, dynamic>?;

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    _user = null;
    _organization = null;
    _isAuthenticated = false;
    _isLoading = false;

    notifyListeners();
  }
}
