import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_name';
  static const _keyOrgName = 'org_name';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  static Future<void> saveUserInfo({
    required String email,
    required String name,
    required String orgName,
  }) async {
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyOrgName, value: orgName);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final email = await _storage.read(key: _keyUserEmail);
    final name = await _storage.read(key: _keyUserName);
    final orgName = await _storage.read(key: _keyOrgName);
    return {'email': email, 'name': name, 'org_name': orgName};
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
