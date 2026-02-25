import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Platform-aware token storage:
/// - Mobile/Desktop → flutter_secure_storage (encrypted)
/// - Web → shared_preferences (for browser preview only)
class TokenStorage {
  static const _key = 'jwt_token';
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<void> write(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
    } else {
      await _secure.write(key: _key, value: token);
    }
  }

  static Future<String?> read() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    } else {
      return await _secure.read(key: _key);
    }
  }

  static Future<void> delete() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } else {
      await _secure.delete(key: _key);
    }
  }
}
