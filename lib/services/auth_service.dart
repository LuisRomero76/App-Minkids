import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minkids/services/api_service.dart';
import 'package:minkids/utils/constants.dart';
import 'package:minkids/models/user.dart';

class AuthService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isLoggedIn() async {
    _prefs ??= await SharedPreferences.getInstance();
    final token = _prefs!.getString(kTokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await ApiService.post('/auth/login', {'email': email, 'password': password});
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      // try common keys
      final token = body['token'] ?? body['access_token'] ?? body['accessToken'];
      final user = body['user'] ?? body['data'] ?? body;
      if (token != null) {
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs!.setString(kTokenKey, token.toString());
      }
      if (user != null && user is Map<String, dynamic>) {
        await _prefs!.setString(kUserKey, jsonEncode(user));
      }
      return {'ok': true, 'body': body};
    }
    return {'ok': false, 'body': body};
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String rol) async {
    final resp = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'rol': rol,
    });
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // server may return created user including code
      return {'ok': true, 'body': body};
    }
    return {'ok': false, 'body': body};
  }

  static Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(kTokenKey);
    await _prefs!.remove(kUserKey);
  }

  static Future<UserModel?> currentUser() async {
    _prefs ??= await SharedPreferences.getInstance();
    final s = _prefs!.getString(kUserKey);
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(kUserKey, jsonEncode(userData));
  }
}
