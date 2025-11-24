import 'dart:convert';
import 'package:minkids/services/api_service.dart';
import 'package:minkids/models/child.dart';

class ParentChildrenService {
  static Future<List<ChildModel>> getMyChildren() async {
    try {
      final resp = await ApiService.get('/parent-children/my-children', auth: true);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((json) => ChildModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMyParents() async {
    try {
      final resp = await ApiService.get('/parent-children/my-parents', auth: true);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data
            .map((e) => e is Map<String, dynamic>
                ? (e['parent'] is Map<String, dynamic>
                    ? Map<String, dynamic>.from(e['parent'])
                    : Map<String, dynamic>.from(e))
                : <String, dynamic>{})
            .where((m) => m.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addChild(String code) async {
    try {
      final resp = await ApiService.post('/parent-children/add', {
        'child_code': code,
      }, auth: true);
      final body = jsonDecode(resp.body);
      final ok = resp.statusCode == 200 || resp.statusCode == 201;
      return {
        'ok': ok,
        'body': body,
        'status': resp.statusCode,
      };
    } catch (e) {
      return {
        'ok': false,
        'body': {'message': 'Error de red'},
        'status': 0,
      };
    }
  }
}
