import 'package:flutter/material.dart';
import 'package:minkids/models/child.dart';
import 'package:minkids/models/application.dart';
import 'package:minkids/models/app_limit.dart';
import 'package:minkids/services/applications_service.dart';
import 'package:minkids/services/limits_service.dart';
import 'package:minkids/services/parent_children_service.dart';

class ParentAppConfigScreen extends StatefulWidget {
  const ParentAppConfigScreen({super.key});

  @override
  State<ParentAppConfigScreen> createState() => _ParentAppConfigScreenState();
}

class _ParentAppConfigScreenState extends State<ParentAppConfigScreen> {
  List<ChildModel> _children = [];
  List<ApplicationModel> _allApps = [];
  List<AppLimitModel> _limits = [];
  ChildModel? _selectedChild;
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _loading = true);
    final children = await ParentChildrenService.getMyChildren();
    final apps = await ApplicationsService.getAll();
    
    setState(() {
      _children = children;
      _allApps = apps;
      _loading = false;
      if (children.isNotEmpty) {
        _selectedChild = children.first;
        _loadLimits();
      }
    });
  }

  Future<void> _loadLimits() async {
    if (_selectedChild == null) return;
    
    setState(() => _loading = true);
    final limits = await LimitsService.getLimitsForChild(_selectedChild!.userId);
    setState(() {
      _limits = limits;
      _loading = false;
    });
  }

  Future<void> _toggleAppControl(ApplicationModel app, bool enabled) async {
    if (_selectedChild == null) return;

    // Buscar si ya existe un límite
    final existingLimit = _limits.firstWhere(
      (limit) => limit.appId == app.appId,
      orElse: () => AppLimitModel(
        id: 0,
        childId: _selectedChild!.userId,
        appId: app.appId,
        dailyLimitMinutes: 60,
        enabled: false,
      ),
    );

    if (existingLimit.id == 0) {
      // Crear nuevo límite
      final success = await LimitsService.createLimit(
        childId: _selectedChild!.userId,
        appId: app.appId,
        dailyLimitMinutes: 60,
        enabled: enabled,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Control activado correctamente')),
        );
        _loadLimits();
      }
    } else {
      // Actualizar límite existente
      final success = await LimitsService.updateLimit(
        limitId: existingLimit.id,
        enabled: enabled,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(enabled ? 'Control activado' : 'Control desactivado')),
        );
        _loadLimits();
      }
    }
  }

  Future<void> _updateLimit(AppLimitModel limit, int newLimit) async {
    final success = await LimitsService.updateLimit(
      limitId: limit.id,
      dailyLimitMinutes: newLimit,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Límite actualizado correctamente')),
      );
      _loadLimits();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar límite'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditLimitDialog(ApplicationModel app, AppLimitModel? existingLimit) {
    final controller = TextEditingController(
      text: existingLimit?.dailyLimitMinutes.toString() ?? '60',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurar límite - ${app.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Límite diario en minutos',
                suffixText: 'min',
                helperText: 'Tiempo máximo de uso diario',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Package: ${app.packageName}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final minutes = int.tryParse(controller.text);
              if (minutes == null || minutes < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un número válido')),
                );
                return;
              }

              Navigator.pop(context);

              if (existingLimit != null) {
                await _updateLimit(existingLimit, minutes);
              } else {
                // Crear nuevo límite
                final success = await LimitsService.createLimit(
                  childId: _selectedChild!.userId,
                  appId: app.appId,
                  dailyLimitMinutes: minutes,
                  enabled: true,
                );
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Límite configurado correctamente')),
                  );
                  _loadLimits();
                }
              }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_children.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.family_restroom, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No tienes hijos vinculados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega un hijo para comenzar',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Aplicaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Selector de hijo
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.child_care, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ChildModel>(
                    value: _selectedChild,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar hijo',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _children.map((child) {
                      return DropdownMenuItem(
                        value: child,
                        child: Text(child.name),
                      );
                    }).toList(),
                    onChanged: (child) {
                      setState(() => _selectedChild = child);
                      _loadLimits();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar aplicación...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Lista de apps
          Expanded(
            child: _allApps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.apps_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No hay aplicaciones registradas'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allApps.length,
                    itemBuilder: (context, index) {
                      final app = _allApps[index];
                      
                      // Filtrar por búsqueda
                      if (_searchCtrl.text.isNotEmpty &&
                          !app.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) &&
                          !app.packageName.toLowerCase().contains(_searchCtrl.text.toLowerCase())) {
                        return const SizedBox.shrink();
                      }

                      final limit = _limits.firstWhere(
                        (l) => l.appId == app.appId,
                        orElse: () => AppLimitModel(
                          id: 0,
                          childId: _selectedChild!.userId,
                          appId: app.appId,
                          dailyLimitMinutes: 60,
                          enabled: false,
                        ),
                      );

                      final hasLimit = limit.id != 0;
                      final isEnabled = hasLimit && limit.enabled;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isEnabled 
                                        ? Colors.green.shade100 
                                        : Colors.grey.shade200,
                                    child: Icon(
                                      _getAppIcon(app.packageName),
                                      color: isEnabled ? Colors.green.shade700 : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hasLimit 
                                              ? 'Límite: ${limit.dailyLimitMinutes} min/día'
                                              : 'Sin límite configurado',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isEnabled,
                                    onChanged: (val) => _toggleAppControl(app, val),
                                  ),
                                ],
                              ),
                              if (isEnabled) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showEditLimitDialog(app, limit),
                                        icon: const Icon(Icons.timer, size: 18),
                                        label: const Text('Configurar Límite'),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (!hasLimit) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showEditLimitDialog(app, null),
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  label: const Text('Establecer Límite'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 40),
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
