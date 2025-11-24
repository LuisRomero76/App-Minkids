import 'package:flutter/material.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/services/parent_children_service.dart';
import 'package:minkids/services/user_service.dart';
import 'package:minkids/models/user.dart';
import 'package:minkids/models/child.dart';
import 'package:minkids/services/child_location_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeTab({super.key, required this.onNavigate});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  UserModel? _user;
  List<ChildModel> _children = [];
  List<Map<String, dynamic>> _parents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos cada vez que se vuelve a esta pantalla
    _load();
  }

  void _load() async {
    final user = await AuthService.currentUser();
    setState(() => _user = user);

    if (user?.rol == 'padre') {
      final children = await ParentChildrenService.getMyChildren();
      setState(() {
        _children = children;
        _loading = false;
      });
    } else if (user?.rol == 'hijo' && user?.userId != null) {
      // Obtener datos actualizados del usuario hijo para obtener el código
      try {
        final allUsers = await UserService.getAllUsers();
        final currentUserData = allUsers.firstWhere(
          (u) => u.userId == user!.userId,
          orElse: () => user!,
        );
        print('Usuario encontrado: ${currentUserData.name}, Código: ${currentUserData.code}'); // Debug
        // Obtener padres vinculados
        final parents = await ParentChildrenService.getMyParents();
        setState(() {
          _user = currentUserData;
          _parents = parents;
          _loading = false;
        });
      } catch (e) {
        print('Error al obtener usuario: $e'); // Debug
        setState(() => _loading = false);
      }
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
    final name = _user?.name ?? 'Usuario';

    if (rol == 'padre') {
      return _buildParentHome(name);
    } else {
      return _buildChildHome(name);
    }
  }

  Widget _buildParentHome(String name) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, padre MinKids!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí tienes un resumen rápido del día de tu hijo.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSummaryCard(
              icon: Icons.access_time,
              title: 'Uso de Aplicaciones',
              subtitle: 'Límite: 3h 0min (82% usado)',
              color: Colors.blue,
              onTap: () => widget.onNavigate(1),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.location_on,
              title: 'Última Ubicación',
              subtitle: 'Actualizado hace 5 min',
              color: Colors.orange,
              onTap: () => widget.onNavigate(2),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.lightbulb_outline,
              title: 'Consejo del Día',
              subtitle: 'Un buen balance ayuda a su desarrollo.',
              color: Colors.indigo,
              onTap: () => widget.onNavigate(3),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Hijos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_children.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.person_add_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes hijos registrados',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showAddChildDialog,
                        child: const Text('Agregar Hijo'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._children.map((child) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(child.name[0].toUpperCase()),
                      ),
                      title: Text(child.name),
                      subtitle: Text(child.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  )),
            if (_children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _showAddChildDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar Hijo'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddChildDialog() {
    final controller = TextEditingController();
    bool loading = false;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Hijo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Código del hijo',
            hintText: 'Ingresa el código de vinculación',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un código')));
                return;
              }
              if (loading) return;
              loading = true;
              final res = await ParentChildrenService.addChild(code);
              if (!mounted) return;
              loading = false;
              Navigator.of(ctx).pop();
              if (res['ok'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hijo agregado: $code')));
                // Capturar ubicación del hijo recién vinculado
                await _captureChildLocation(code);
                _load();
              } else {
                final body = res['body'];
                final msg = body is Map && body['message'] != null ? body['message'].toString() : 'Error: verifica el código';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureChildLocation(String childCode) async {
    try {
      // Solicitar ubicación del hijo
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever || 
          permission == LocationPermission.denied) {
        print('Permisos de ubicación denegados');
        return;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final success = await ChildLocationService.registerMyLocation(
        position.latitude,
        position.longitude,
      );
      
      if (success) {
        print('Ubicación registrada: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      print('Error capturando ubicación: $e');
    }
  }

  Widget _buildChildHome(String name) {
    final code = _user?.code ?? '';
    final hasCode = code.isNotEmpty && code != 'null' && code != 'N/A';
    final parent = _parents.isNotEmpty ? _parents.first : null;
    final parentName = parent != null ? (parent['name'] ?? parent['full_name'] ?? '').toString() : '';
    final parentEmail = parent != null ? (parent['email'] ?? '').toString() : '';
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $name!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu resumen de hoy',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_2, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Código de Vinculación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          hasCode ? code : 'Sin código asignado',
                          style: TextStyle(
                            fontSize: hasCode ? 24 : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: hasCode ? 3 : 0,
                            color: hasCode ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasCode
                          ? 'Comparte este código con tu padre para vincularte'
                          : 'El código se generará automáticamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Padre Vinculado',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          if (parentName.isNotEmpty)
                            Text(parentName, style: const TextStyle(fontSize: 16))
                          else
                            Text(
                              'Aún no estás vinculado a un padre',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          if (parentEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(parentEmail, style: TextStyle(color: Colors.grey[600])),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.access_time,
              title: 'Uso de Aplicaciones',
              subtitle: 'Consulta tu tiempo disponible',
              color: Colors.blue,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
