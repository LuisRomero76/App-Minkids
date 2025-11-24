import 'package:flutter/material.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/services/limits_service.dart';
import 'package:minkids/services/applications_service.dart';
import 'package:minkids/models/user.dart';
import 'package:minkids/models/app_limit.dart';
import 'package:minkids/models/application.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  UserModel? _user;
  List<AppLimitModel> _limits = [];
  List<ApplicationModel> _allApps = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final user = await AuthService.currentUser();
    setState(() => _user = user);

    if (user?.rol == 'hijo' && user?.userId != null) {
      // Hijo: ver sus propios límites
      final limits = await LimitsService.getLimitsForChild(user!.userId!);
      setState(() {
        _limits = limits;
        _loading = false;
      });
    } else if (user?.rol == 'padre') {
      // Padre: cargar apps disponibles (para este ejemplo, mostrar placeholder)
      // En producción, aquí cargarías los hijos y seleccionarías uno
      final apps = await ApplicationsService.getAll();
      setState(() {
        _allApps = apps;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rol = _user?.rol ?? 'hijo';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rol == 'padre' ? 'Control de Aplicaciones' : 'Mis Aplicaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar aplicación...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: rol == 'hijo' ? _buildChildAppsList() : _buildParentAppsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChildAppsList() {
    if (_limits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes límites configurados',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _limits.length,
      itemBuilder: (context, index) {
        final limit = _limits[index];
        final app = limit.application;
        final appName = app?.name ?? 'App ${limit.appId}';
        final packageName = app?.packageName ?? '';
        
        // Mock: tiempo usado (en producción, consumir endpoint de uso)
        final usedMinutes = (limit.dailyLimitMinutes * 0.8).round();
        final remainingMinutes = limit.dailyLimitMinutes - usedMinutes;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(_getAppIcon(packageName), color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            limit.enabled ? 'Tiempo agotado' : 'Bloqueada',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: limit.enabled,
                      onChanged: null, // Solo lectura para hijo
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: usedMinutes / limit.dailyLimitMinutes,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingMinutes > 0 ? Colors.blue : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$remainingMinutes min restantes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Límite de tiempo: ${limit.dailyLimitMinutes} min',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParentAppsList() {
    if (_allApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay aplicaciones registradas',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Primero selecciona un hijo para configurar límites',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Mock list para demostración
    final mockApps = [
      {'name': 'TikTok', 'icon': Icons.video_library, 'limit': 60, 'used': 60},
      {'name': 'Instagram', 'icon': Icons.photo_camera, 'limit': 120, 'used': 30},
      {'name': 'YouTube', 'icon': Icons.play_circle, 'limit': 90, 'used': 90},
    ];

    return ListView.builder(
      itemCount: mockApps.length,
      itemBuilder: (context, index) {
        final app = mockApps[index];
        final used = app['used'] as int;
        final limit = app['limit'] as int;
        final remaining = limit - used;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(app['icon'] as IconData, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        app['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (val) {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (remaining <= 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tiempo agotado',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: used / limit,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$remaining min restantes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Límite de tiempo: $limit min',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        _showEditLimitDialog(app['name'] as String, limit);
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Establecer Límite'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditLimitDialog(String appName, int currentLimit) {
    final controller = TextEditingController(text: currentLimit.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar límite - $appName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Límite en minutos',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí llamarías a LimitsService.updateLimit
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Límite actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  IconData _getAppIcon(String packageName) {
    if (packageName.contains('tiktok')) return Icons.video_library;
    if (packageName.contains('instagram')) return Icons.photo_camera;
    if (packageName.contains('youtube')) return Icons.play_circle;
    return Icons.apps;
  }
}
