import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// EXCEPTION
// ─────────────────────────────────────────────

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

// ─────────────────────────────────────────────
// SESSION STORE (SharedPreferences helpers)
// ─────────────────────────────────────────────

class SessionStore {
  static const _keyToken    = 'auth_token';
  static const _keyUserId   = 'user_id';
  static const _keyRole     = 'user_role';
  static const _keyEmail    = 'user_email';
  static const _keyFullName = 'user_full_name';
  static const _keyImageUrl = 'user_image_url';
  static const _keyLoggedIn = 'is_logged_in';

  static Future<void> saveSession({
    required String token,
    required int    userId,
    required String role,
    required String email,
    required String fullName,
    String?         imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool  (_keyLoggedIn, true);
    await prefs.setString(_keyToken,    token);
    await prefs.setInt   (_keyUserId,   userId);
    await prefs.setString(_keyRole,     role);
    await prefs.setString(_keyEmail,    email);
    await prefs.setString(_keyFullName, fullName);
    if (imageUrl != null) await prefs.setString(_keyImageUrl, imageUrl);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyImageUrl);
  }

  static Future<String?> getToken()    async => (await SharedPreferences.getInstance()).getString(_keyToken);
  static Future<int?>    getUserId()   async => (await SharedPreferences.getInstance()).getInt(_keyUserId);
  static Future<String?> getRole()     async => (await SharedPreferences.getInstance()).getString(_keyRole);
  static Future<String?> getEmail()    async => (await SharedPreferences.getInstance()).getString(_keyEmail);
  static Future<String?> getFullName() async => (await SharedPreferences.getInstance()).getString(_keyFullName);
  static Future<String?> getImageUrl() async => (await SharedPreferences.getInstance()).getString(_keyImageUrl);
  static Future<bool>    isLoggedIn()  async => (await SharedPreferences.getInstance()).getBool(_keyLoggedIn) ?? false;
}

// ─────────────────────────────────────────────
// BASE SERVICE
// ─────────────────────────────────────────────

abstract class BaseService {
  // Change to 10.0.2.2 when targeting Android emulator
  static const String baseUrl = 'http://localhost:8080';
  static const Duration _timeout = Duration(seconds: 15);

  // ── Auth header ───────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await SessionStore.getToken();
    return {
      'Accept':       'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── HTTP verbs ────────────────────────────────────────────────────────────

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    try {
      return await http.get(uri, headers: await _headers()).timeout(_timeout);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(0, 'Network error. Please check your connection.');
    }
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      return await http
          .post(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(0, 'Network error. Please check your connection.');
    }
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      return await http
          .put(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(0, 'Network error. Please check your connection.');
    }
  }

  Future<http.Response> patch(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      return await http
          .patch(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(0, 'Network error. Please check your connection.');
    }
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      return await http.delete(uri, headers: await _headers()).timeout(_timeout);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(0, 'Network error. Please check your connection.');
    }
  }

  Future<http.Response> uploadFile(String path, List<int> bytes, String filename) async {
    final uri = Uri.parse('$baseUrl$path');
    final token = await SessionStore.getToken();
    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        })
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException(0, 'Network error. Please check your connection.');
    }
  }

  // ── Response handling ─────────────────────────────────────────────────────

  /// Throws [ApiException] for any non-2xx response.
  void guard(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    _throwFromBody(res);
  }

  static Never _throwFromBody(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final msg = body is Map
          ? (body['message'] ?? body['error'] ?? 'Something went wrong.')
          : 'Something went wrong.';
      throw ApiException(res.statusCode, msg.toString());
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(res.statusCode, 'Server error (${res.statusCode}).');
    }
  }

  /// Decode body and call [guard] in one step.
  dynamic decode(http.Response res) {
    guard(res);
    return jsonDecode(res.body);
  }
}