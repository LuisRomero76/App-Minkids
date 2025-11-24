import 'package:flutter/material.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/services/child_location_service.dart';
import 'package:geolocator/geolocator.dart';

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
      
      // Capturar ubicación si es hijo
      if (_rol == 'hijo' && loginRes['ok'] == true) {
        try {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            final position = await Geolocator.getCurrentPosition();
            await ChildLocationService.registerMyLocation(position.latitude, position.longitude);
          }
        } catch (e) {
          print('Error capturando ubicación: $e');
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.green.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizado
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        
                        // Logo con círculo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'lib/assets/logo.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Título con colores MinKids
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Únete a ',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              TextSpan(
                                text: 'Mind',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              TextSpan(
                                text: 'Kids',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Subtítulo
                        Text(
                          'Completa tus datos para comenzar.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                
                        // Card contenedor de campos
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Campo de Nombre
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade600),
                                  hintText: 'Nombre completo',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                              ),
                              const SizedBox(height: 14),
                              
                              // Campo de Email
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.green.shade600),
                                  hintText: 'Correo Electrónico',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                              ),
                              const SizedBox(height: 14),
                              
                              // Campo de Contraseña
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade600),
                                  hintText: 'Contraseña',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                              ),
                              const SizedBox(height: 14),
                              
                              // Campo de Confirmar Contraseña
                              TextFormField(
                                controller: _confirmPassCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade600),
                                  hintText: 'Confirmar Contraseña',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
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
                              const SizedBox(height: 14),
                              
                              // Campo de Rol
                              DropdownButtonFormField<String>(
                                value: _rol,
                                items: [
                                  DropdownMenuItem(
                                    value: 'padre',
                                    child: Row(
                                      children: [
                                        Icon(Icons.family_restroom, size: 20, color: Colors.blue.shade600),
                                        const SizedBox(width: 12),
                                        const Text('Padre'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hijo',
                                    child: Row(
                                      children: [
                                        Icon(Icons.child_care, size: 20, color: Colors.green.shade600),
                                        const SizedBox(width: 12),
                                        const Text('Hijo'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _rol = v ?? 'hijo'),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.supervised_user_circle_outlined, color: Colors.indigo.shade600),
                                  hintText: 'Selecciona tu rol',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Botón Registrar con gradiente
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade600, Colors.green.shade500],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Crear Cuenta',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
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
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Inicia Sesión',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }
}
