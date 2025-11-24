import 'package:flutter/material.dart';
import 'package:minkids/models/app_limit.dart';
import 'package:minkids/services/limits_service.dart';
import 'package:minkids/services/app_usage_tracker.dart';
import 'package:minkids/services/app_blocker_plugin.dart';
import 'dart:async';

class ChildAppsScreen extends StatefulWidget {
  const ChildAppsScreen({super.key});

  @override
  State<ChildAppsScreen> createState() => _ChildAppsScreenState();
}

class _ChildAppsScreenState extends State<ChildAppsScreen> {
  List<AppLimitModel> _limits = [];
  Map<String, int> _usageMinutes = {};
  bool _loading = true;
  bool _accessibilityEnabled = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
    
    // Refrescar cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadUsageData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadMyLimits();
    await _loadUsageData();
    await _checkAccessibilityService();
  }

  Future<void> _loadMyLimits() async {
    setState(() => _loading = true);
    final limits = await LimitsService.getMyLimits();
    setState(() {
      _limits = limits;
      _loading = false;
    });
  }

  Future<void> _loadUsageData() async {
    // Obtener uso desde SharedPreferences (guardado por AppUsageTracker)
    final usage = await AppUsageTracker.getAllUsageToday();
    
    setState(() {
      _usageMinutes = usage;
    });
    
    // Actualizar apps bloqueadas según el uso actual
    await AppBlockerPlugin.updateBlockedAppsWithUsage(_limits, usage);
  }

  Future<void> _checkAccessibilityService() async {
    final enabled = await AppBlockerPlugin.isAccessibilityServiceEnabled();
    setState(() {
      _accessibilityEnabled = enabled;
    });
  }

  IconData _getAppIcon(String packageName) {
    if (packageName.contains('tiktok')) return Icons.video_library;
    if (packageName.contains('instagram')) return Icons.photo_camera;
    if (packageName.contains('youtube')) return Icons.play_circle;
    if (packageName.contains('facebook')) return Icons.facebook;
    if (packageName.contains('whatsapp')) return Icons.message;
    if (packageName.contains('twitter') || packageName.contains('x.')) return Icons.flutter_dash;
    if (packageName.contains('snapchat')) return Icons.camera_alt;
    if (packageName.contains('spotify')) return Icons.music_note;
    if (packageName.contains('netflix')) return Icons.movie;
    if (packageName.contains('telegram')) return Icons.send;
    if (packageName.contains('discord')) return Icons.discord;
    if (packageName.contains('roblox') || packageName.contains('minecraft') ||
        packageName.contains('game')) return Icons.sports_esports;
    if (packageName.contains('chrome')) return Icons.public;
    if (packageName.contains('gmail')) return Icons.email;
    if (packageName.contains('maps')) return Icons.map;
    return Icons.apps;
  }

  Color _getLimitColor(int usedMinutes, int limitMinutes) {
    final percentage = (usedMinutes / limitMinutes) * 100;
    if (percentage >= 90) return Colors.red;
    if (percentage >= 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Filtrar solo los límites que están habilitados
    final activeLimits = _limits.where((limit) => limit.enabled).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Aplicaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMyLimits();
              _loadUsageData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de advertencia si no está habilitado el servicio
          if (!_accessibilityEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control parental desactivado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const Text(
                          'Habilita el servicio de accesibilidad para activar el bloqueo',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await AppBlockerPlugin.requestAccessibilityPermission();
                    },
                    child: const Text('Activar'),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: activeLimits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Sin restricciones activas!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Puedes usar tus apps libremente',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeLimits.length,
                    itemBuilder: (context, index) {
                      final limit = activeLimits[index];
                      final app = limit.application;

                      if (app == null) return const SizedBox.shrink();

                      // Obtener uso real desde el tracker
                      final usedMinutes = _usageMinutes[app.packageName] ?? 0;
                      final limitMinutes = limit.dailyLimitMinutes;
                      final remainingMinutes = (limitMinutes - usedMinutes).clamp(0, limitMinutes);
                      final percentage = (usedMinutes / limitMinutes).clamp(0.0, 1.0);
                      final isBlocked = usedMinutes >= limitMinutes;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isBlocked ? 4 : 2,
                        color: isBlocked ? Colors.red.shade50 : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getLimitColor(usedMinutes, limitMinutes).withOpacity(0.2),
                                    child: Icon(
                                      isBlocked ? Icons.lock : _getAppIcon(app.packageName),
                                      color: _getLimitColor(usedMinutes, limitMinutes),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                app.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            if (isBlocked)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade700,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'BLOQUEADA',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Límite diario: $limitMinutes minutos',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isBlocked ? '0 min' : '$remainingMinutes min',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: _getLimitColor(usedMinutes, limitMinutes),
                                        ),
                                      ),
                                      Text(
                                        'restantes',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getLimitColor(usedMinutes, limitMinutes),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Usado: $usedMinutes min',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${(percentage * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getLimitColor(usedMinutes, limitMinutes),
                                    ),
                                  ),
                                ],
                              ),
                              if (isBlocked) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade700),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info, color: Colors.red.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Has alcanzado tu límite diario. Esta aplicación está bloqueada hasta mañana.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
