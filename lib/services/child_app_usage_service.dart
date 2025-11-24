import 'dart:convert';
import 'package:minkids/services/api_service.dart';

class ChildAppUsageService {
  /// Registra el uso de una app específica
  static Future<bool> registrarUso({
    required int appId,
    required int durationMinutes,
    DateTime? usageDate,
  }) async {
    try {
      final resp = await ApiService.post('/child-app-usage/registrar', {
        'app_id': appId,
        'duration_minutes': durationMinutes,
        'usage_date': (usageDate ?? DateTime.now()).toIso8601String(),
      }, auth: true);
      
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      print('Error registrando uso: $e');
      return false;
    }
  }

  /// Sincroniza múltiples apps con el backend
  /// packageUsage: { "com.tiktok": 45, "com.instagram": 30 }
  static Future<void> syncUsage(Map<String, int> packageUsage) async {
    try {
      final resp = await ApiService.post('/child-app-usage/sync', {
        'usage_data': packageUsage,
        'date': DateTime.now().toIso8601String(),
      }, auth: true);
      
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        print('✅ Uso sincronizado correctamente');
      }
    } catch (e) {
      print('Error sincronizando uso: $e');
    }
  }

  /// Obtiene el uso de hoy para todas las apps del hijo actual
  static Future<Map<String, int>> getUsageToday() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day).toIso8601String();
      
      final resp = await ApiService.get(
        '/child-app-usage/today?date=$today',
        auth: true,
      );
      
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        final Map<String, int> usage = {};
        
        for (var item in data) {
          final packageName = item['application']?['package_name'] as String?;
          final minutes = item['total_minutes'] as int? ?? 0;
          
          if (packageName != null) {
            usage[packageName] = minutes;
          }
        }
        
        return usage;
      }
      
      return {};
    } catch (e) {
      print('Error obteniendo uso: $e');
      return {};
    }
  }

  /// Obtiene el uso histórico (últimos 7 días)
  static Future<List<Map<String, dynamic>>> getUsageHistory({int days = 7}) async {
    try {
      final resp = await ApiService.get(
        '/child-app-usage/history?days=$days',
        auth: true,
      );
      
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('Error obteniendo historial: $e');
      return [];
    }
  }
}
