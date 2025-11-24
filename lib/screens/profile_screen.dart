import 'package:flutter/material.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/models/user.dart';
import 'package:minkids/screens/add_child_screen.dart';
import 'package:minkids/services/child_location_service.dart';
import 'package:minkids/services/realtime_location_service.dart';
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _updatingLocation = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final u = await AuthService.currentUser();
    setState(() => _user = u);
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _updateLocation() async {
    setState(() => _updatingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final success = await ChildLocationService.registerMyLocation(position.latitude, position.longitude);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Ubicación actualizada correctamente' : 'Error al actualizar ubicación'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se necesitan permisos de ubicación')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.name ?? 'Usuario';
    final email = _user?.email ?? '';
    final rol = _user?.rol ?? 'hijo';
    final code = _user?.code;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name),
                subtitle: Text(email),
                trailing: IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Preferencias de notificación', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(title: const Text('Alertas de Límites de Aplicaciones'), value: true, onChanged: (_) {}),
            ),
            Card(child: SwitchListTile(title: const Text('Alertas de Ubicación'), value: false, onChanged: (_) {})),
            Card(child: SwitchListTile(title: const Text('Nuevos Consejos'), value: true, onChanged: (_) {})),
            const SizedBox(height: 16),
            if (rol == 'hijo' && code != null) ...[
              const Text('Código de Vinculación', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Text(code))),
              const SizedBox(height: 16),
              const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Estado del tracking en tiempo real
              Card(
                color: RealtimeLocationService.isTracking ? Colors.green.shade50 : Colors.grey.shade50,
                child: ListTile(
                  leading: Icon(
                    RealtimeLocationService.isTracking ? Icons.my_location : Icons.location_disabled,
                    color: RealtimeLocationService.isTracking ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    RealtimeLocationService.isTracking 
                      ? 'Compartiendo ubicación' 
                      : 'Ubicación no compartida'
                  ),
                  subtitle: Text(
                    RealtimeLocationService.isTracking
                      ? 'Actualizando cada 30 segundos'
                      : 'Inicia la app para compartir',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: RealtimeLocationService.isTracking
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTIVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text('Actualizar mi ubicación'),
                  subtitle: const Text('Envía tu ubicación actual manualmente'),
                  trailing: _updatingLocation 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  onTap: _updatingLocation ? null : _updateLocation,
                ),
              ),
            ],
            if (rol == 'padre') ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddChildScreen())), icon: const Icon(Icons.person_add), label: const Text('Agregar Hijo'))
            ]
          ],
        ),
      ),
    );
  }
}
