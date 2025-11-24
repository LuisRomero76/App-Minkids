import 'dart:convert';
import 'package:minkids/services/api_service.dart';
import 'package:minkids/models/application.dart';

class ApplicationsService {
  static Future<List<ApplicationModel>> getAll() async {
    try {
      final resp = await ApiService.get('/applications', auth: true);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((json) => ApplicationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
