import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import 'token_storage.dart';

class AuthService {
  // Android emulator → use 'http://10.0.2.2:5103/api/auth'
  // Windows desktop → use 'http://localhost:5103/api/auth'
  static const String _baseUrl = 'http://localhost:5103/api/auth';

  /// Register a new user
  Future<AuthResponse?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.write(auth.token);
      return auth;
    }
    return null;
  }

  /// Login an existing user
  Future<AuthResponse?> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.write(auth.token);
      return auth;
    }
    return null;
  }

  Future<String?> getToken() async => await TokenStorage.read();

  Future<void> logout() async => await TokenStorage.delete();

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.read();
    return token != null && token.isNotEmpty;
  }
}
