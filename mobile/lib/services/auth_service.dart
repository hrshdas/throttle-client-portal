import '../core/api/api_client.dart';
import '../core/storage/auth_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      requireAuth: false,
    );
    final accessToken = res['access_token'] as String;
    final refreshToken = res['refresh_token'] as String;

    await AuthStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return res;
  }

  static Future<Map<String, dynamic>> getInvitationDetails(String token) async {
    final res = await ApiClient.get('/auth/invitation/$token', requireAuth: false);
    return res as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> acceptInvitation({
    required String token,
    required String name,
    required String password,
  }) async {
    final res = await ApiClient.post(
      '/auth/accept-invitation',
      body: {
        'token': token,
        'name': name,
        'password': password,
      },
      requireAuth: false,
    );

    final accessToken = res['access_token'] as String;
    final refreshToken = res['refresh_token'] as String;

    await AuthStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return res;
  }

  static Future<void> logout() async {
    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken != null) {
        await ApiClient.post('/auth/logout', body: {'refresh_token': refreshToken});
      }
    } catch (_) {}
    await AuthStorage.clearAll();
  }
}
