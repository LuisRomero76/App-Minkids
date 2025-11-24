import 'dart:convert';
import 'package:minkids/services/api_service.dart';
import 'package:minkids/models/app_limit.dart';

class LimitsService {
  static Future<List<AppLimitModel>> getLimitsForChild(int childId) async {
    try {
      final resp = await ApiService.get('/child-app-limits/child/$childId', auth: true);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((json) => AppLimitModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<AppLimitModel>> getMyLimits() async {
    try {
      final resp = await ApiService.get('/child-app-limits/my-limits', auth: true);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((json) => AppLimitModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createLimit({
    required int childId,
    required int appId,
    required int dailyLimitMinutes,
    bool enabled = true,
  }) async {
    try {
      final resp = await ApiService.post('/child-app-limits', {
        'child_id': childId,
        'app_id': appId,
        'daily_limit_minutes': dailyLimitMinutes,
        'enabled': enabled,
      }, auth: true);
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateLimit({
    required int limitId,
    int? dailyLimitMinutes,
    bool? enabled,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (dailyLimitMinutes != null) body['daily_limit_minutes'] = dailyLimitMinutes;
      if (enabled != null) body['enabled'] = enabled;
      
      final resp = await ApiService.patch('/child-app-limits/$limitId', body, auth: true);
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteLimit(int limitId) async {
    try {
      final resp = await ApiService.delete('/child-app-limits/$limitId', auth: true);
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

