import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  // Use 10.0.2.2 for Android emulator (maps to host localhost).
  // For web/Windows desktop use localhost directly.
  static const String _baseUrl = 'http://localhost:8080/api/auth';

  /// Login with username/email + password.
  /// Sends: { "usernameOrEmail": "...", "password": "..." }
  static Future<String> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');
    late http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'usernameOrEmail': usernameOrEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw const AuthException('Network error. Please check your connection.');
    }

    if (response.statusCode == 200) {
      final token = _extractToken(response.body);
      await _saveSession(token);
      return token;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthException('Invalid username or password.');
    } else {
      _throwFromBody(response);
    }
    return '';
  }

  /// Register a new user account.
  /// Sends the full body matching the backend schema.
  static Future<String> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');
    late http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
              'phoneNumber': phoneNumber,
              'role': 'PATIENT',
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw const AuthException('Network error. Please check your connection.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = _extractToken(response.body);
      await _saveSession(token);
      return token;
    } else if (response.statusCode == 409) {
      throw const AuthException('An account with this email already exists.');
    } else {
      _throwFromBody(response);
    }
    return '';
  }

  /// Logout — clear stored credentials.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('auth_token');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _extractToken(String responseBody) {
    try {
      final body = jsonDecode(responseBody);
      if (body is Map) {
        return (body['token'] ?? body['accessToken'] ?? '').toString();
      }
      return body.toString();
    } catch (_) {
      return '';
    }
  }

  static Future<void> _saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (token.isNotEmpty) {
      await prefs.setString('auth_token', token);
    }
  }

  static Never _throwFromBody(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      final msg = body is Map
          ? (body['message'] ?? body['error'] ?? 'Something went wrong.')
          : 'Something went wrong.';
      throw AuthException(msg.toString());
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Server error (${response.statusCode}).');
    }
  }
}
