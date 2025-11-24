import 'dart:convert';
import 'package:minkids/services/api_service.dart';
import 'package:minkids/models/user.dart';

class UserService {
  static Future<List<UserModel>> getAllUsers() async {
    final resp = await ApiService.get('/user', auth: true);
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    return [];
  }
}
