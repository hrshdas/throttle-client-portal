import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await AuthStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await http.get(uri, headers: headers).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to backend server at ${ApiConfig.baseUrl}. Is the server running?', statusCode: 503);
    } on TimeoutException {
      throw ApiException('Connection timed out. Please check backend server.', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString(), statusCode: 500);
    }
  }

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to backend server at ${ApiConfig.baseUrl}. Is the server running?', statusCode: 503);
    } on TimeoutException {
      throw ApiException('Connection timed out. Please check backend server.', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString(), statusCode: 500);
    }
  }

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to backend server at ${ApiConfig.baseUrl}. Is the server running?', statusCode: 503);
    } on TimeoutException {
      throw ApiException('Connection timed out. Please check backend server.', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString(), statusCode: 500);
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = (body is Map && body.containsKey('detail'))
          ? body['detail'].toString()
          : 'HTTP Error ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}
