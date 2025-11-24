import 'package:flutter/material.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/models/user.dart';
import 'package:minkids/screens/add_child_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

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
