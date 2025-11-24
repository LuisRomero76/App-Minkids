import 'dart:async';
import 'package:usage_stats/usage_stats.dart';
import 'package:minkids/services/child_app_usage_service.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageTracker {
  static Timer? _timer;
  static bool _isTracking = false;

  /// Inicia el monitoreo de uso de apps (solo para hijos)
  static Future<void> startTracking({int intervalMinutes = 5}) async {
    if (_isTracking) return;

    final user = await AuthService.currentUser();
    if (user?.rol != 'hijo') return;

    // Solicitar permisos de uso de apps
    await UsageStats.checkUsagePermission();
    final hasPermission = await UsageStats.checkUsagePermission() ?? false;
    
    if (!hasPermission) {
      // Abrir configuración para otorgar permisos
      await UsageStats.grantUsagePermission();
      return;
    }

    _isTracking = true;
    print('📊 AppUsageTracker iniciado');

    // Sincronizar inmediatamente
    await _syncUsageToServer();

    // Configurar sincronización periódica
    _timer = Timer.periodic(Duration(minutes: intervalMinutes), (_) {
      _syncUsageToServer();
    });
  }

  /// Detiene el monitoreo
  static void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    print('📊 AppUsageTracker detenido');
  }

  /// Sincroniza el uso de apps con el servidor
  static Future<void> _syncUsageToServer() async {
    try {
      final user = await AuthService.currentUser();
      if (user?.userId == null) return;

      // Obtener uso de hoy
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final usageStats = await UsageStats.queryUsageStats(
        startOfDay,
        now,
      );

      if (usageStats == null || usageStats.isEmpty) {
        print('📊 No hay datos de uso');
        return;
      }

      // Agrupar por package name y sumar tiempo
      final Map<String, int> usageByPackage = {};
      for (var stat in usageStats) {
        final packageName = stat.packageName ?? '';
        final totalTimeInForeground = int.tryParse(stat.totalTimeInForeground ?? '0') ?? 0;
        final minutes = (totalTimeInForeground / 60000).round(); // Convertir ms a minutos

        if (packageName.isNotEmpty && minutes > 0) {
          usageByPackage[packageName] = (usageByPackage[packageName] ?? 0) + minutes;
        }
      }

      // Guardar localmente para uso offline
      final prefs = await SharedPreferences.getInstance();
      for (var entry in usageByPackage.entries) {
        await prefs.setInt('usage_${entry.key}', entry.value);
      }

      // Sincronizar con backend
      await ChildAppUsageService.syncUsage(usageByPackage);
      
      print('📊 Sincronizado: ${usageByPackage.length} apps');
    } catch (e) {
      print('❌ Error en sync: $e');
    }
  }

  /// Obtiene el uso de hoy para una app específica (desde local)
  static Future<int> getUsageMinutesToday(String packageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('usage_$packageName') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el uso de hoy para todas las apps (desde local)
  static Future<Map<String, int>> getAllUsageToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('usage_'));
      
      final Map<String, int> usage = {};
      for (var key in keys) {
        final packageName = key.replaceFirst('usage_', '');
        usage[packageName] = prefs.getInt(key) ?? 0;
      }
      
      return usage;
    } catch (e) {
      return {};
    }
  }

  /// Verifica si una app está bloqueada (excedió su límite)
  static Future<bool> isAppBlocked(String packageName, int limitMinutes) async {
    final usedMinutes = await getUsageMinutesToday(packageName);
    return usedMinutes >= limitMinutes;
  }
}
