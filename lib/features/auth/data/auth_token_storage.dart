import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  const AuthTokenStorage();

  static const _tokenKey = 'auth_token';

  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  Future<String?> readToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey)?.trim();
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  Future<void> saveToken(String token) async {
    final normalized = token.trim();
    final prefs = await _prefs;
    if (normalized.isEmpty) {
      await prefs.remove(_tokenKey);
      return;
    }
    await prefs.setString(_tokenKey, normalized);
  }

  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }
}
