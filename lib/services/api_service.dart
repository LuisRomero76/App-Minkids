import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minkids/utils/constants.dart';

class ApiService {
  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final url = Uri.parse(apiPath(path));
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenKey);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> get(String path, {bool auth = false}) async {
    final url = Uri.parse(apiPath(path));
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenKey);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.get(url, headers: headers);
  }

  static Future<http.Response> patch(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final url = Uri.parse(apiPath(path));
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenKey);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.patch(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String path, {bool auth = false}) async {
    final url = Uri.parse(apiPath(path));
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenKey);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return http.delete(url, headers: headers);
  }
}
