import 'package:flutter/material.dart';
import 'package:minkids/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String _rol = 'hijo';
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await AuthService.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim(), _rol);
    setState(() => _loading = false);
    if (res['ok'] == true) {
      final body = res['body'];
      String? code;
      if (body is Map && (body['code'] != null || body['user'] != null)) {
        code = body['code']?.toString() ?? (body['user'] is Map ? body['user']['code']?.toString() : null);
      }
      
      // Auto-login después del registro
      final loginRes = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      
      // Si es hijo y tenemos código, actualizar los datos del usuario en SharedPreferences
      if (_rol == 'hijo' && code != null && loginRes['ok'] == true) {
        final currentUserData = loginRes['body'];
        if (currentUserData is Map) {
          final userData = currentUserData['user'] ?? currentUserData;
          if (userData is Map<String, dynamic>) {
            userData['code'] = code;
            await AuthService.updateUserData(userData);
          }
        }
      }
      
      if (_rol == 'hijo' && code != null) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Código de vinculación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Comparte este código con tu padre:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar'),
              )
            ],
          ),
        );
      }
      
      if (!mounted) return;
      if (loginRes['ok'] == true) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      final body = res['body'];
      final message = body is Map && body['message'] != null ? body['message'] : 'Error en el registro';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Título
                const Center(
                  child: Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtítulo
                Center(
                  child: Text(
                    'Completa tus datos para comenzar.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Campo de Nombre
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Nombre completo',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                
                // Campo de Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'Correo Electrónico',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                
                // Campo de Contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                
                // Campo de Confirmar Contraseña
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Confirmar Contraseña',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de Rol
                DropdownButtonFormField<String>(
                  value: _rol,
                  items: const [
                    DropdownMenuItem(
                      value: 'padre',
                      child: Row(
                        children: [
                          Icon(Icons.family_restroom, size: 20, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Padre'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'hijo',
                      child: Row(
                        children: [
                          Icon(Icons.child_care, size: 20, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Hijo'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _rol = v ?? 'hijo'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.supervised_user_circle_outlined),
                    hintText: 'Selecciona tu rol',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Botón Registrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Ya tienes cuenta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
