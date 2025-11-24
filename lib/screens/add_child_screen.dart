import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:minkids/services/api_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final resp = await ApiService.post('/parent-children/add', {'child_code': _codeCtrl.text.trim()}, auth: true);
    setState(() => _loading = false);
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hijo agregado correctamente')));
      Navigator.of(context).pop();
    } else {
      final message = body is Map && body['message'] != null ? body['message'] : 'Error al agregar hijo';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Hijo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Código del hijo')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Agregar'))
        ]),
      ),
    );
  }
}
