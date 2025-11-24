import 'package:flutter/services.dart';
import 'package:minkids/models/app_limit.dart';

class AppBlockerPlugin {
  static const MethodChannel _channel = MethodChannel('com.example.minkids/app_blocker');

  /// Solicita permisos de accesibilidad
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      print('Error solicitando permisos: $e');
    }
  }

  /// Verifica si el servicio de accesibilidad está habilitado
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } catch (e) {
      print('Error verificando servicio: $e');
      return false;
    }
  }

  /// Actualiza la lista de apps bloqueadas
  static Future<void> updateBlockedApps(List<AppLimitModel> limits) async {
    try {
      // Filtrar apps que están bloqueadas (límite excedido)
      final blockedApps = <String, String>{};
      
      for (var limit in limits) {
        if (limit.enabled && limit.application != null) {
          // Aquí deberías verificar si el uso actual >= límite
          // Por ahora, asumimos que el límite está en el modelo
          blockedApps[limit.application!.packageName] = limit.application!.name;
        }
      }
      
      await _channel.invokeMethod('updateBlockedApps', {'blockedApps': blockedApps});
      print('🔒 Apps bloqueadas actualizadas: ${blockedApps.length}');
    } catch (e) {
      print('Error actualizando apps bloqueadas: $e');
    }
  }

  /// Actualiza apps bloqueadas con información de uso
  static Future<void> updateBlockedAppsWithUsage(
    List<AppLimitModel> limits,
    Map<String, int> usageMinutes,
  ) async {
    try {
      final blockedApps = <String, String>{};
      
      for (var limit in limits) {
        if (!limit.enabled || limit.application == null) continue;
        
        final packageName = limit.application!.packageName;
        final usedMinutes = usageMinutes[packageName] ?? 0;
        
        // Bloquear si excedió el límite
        if (usedMinutes >= limit.dailyLimitMinutes) {
          blockedApps[packageName] = limit.application!.name;
        }
      }
      
      await _channel.invokeMethod('updateBlockedApps', {'blockedApps': blockedApps});
      print('🔒 Apps bloqueadas: ${blockedApps.length} (${blockedApps.keys.join(", ")})');
    } catch (e) {
      print('Error actualizando apps bloqueadas: $e');
    }
  }

  /// Limpia todas las apps bloqueadas
  static Future<void> clearBlockedApps() async {
    try {
      await _channel.invokeMethod('clearBlockedApps');
      print('🔓 Apps desbloqueadas');
    } catch (e) {
      print('Error limpiando apps bloqueadas: $e');
    }
  }
}
