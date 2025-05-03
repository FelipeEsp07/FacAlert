import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ClasificacionDenuncia {
  final int id;
  final String nombre;

  ClasificacionDenuncia({required this.id, required this.nombre});

  factory ClasificacionDenuncia.fromJson(Map<String, dynamic> json) {
    return ClasificacionDenuncia(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

class GestionClasificacionDenunciasScreen extends StatefulWidget {
  const GestionClasificacionDenunciasScreen({Key? key}) : super(key: key);

  @override
  State<GestionClasificacionDenunciasScreen> createState() =>
      _GestionClasificacionDenunciasScreenState();
}

class _GestionClasificacionDenunciasScreenState
    extends State<GestionClasificacionDenunciasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  late final String apiBaseUrl;
  List<ClasificacionDenuncia> _clasificaciones = [];

  @override
  void initState() {
    super.initState();
    apiBaseUrl = Config.apiBase;
    _fetchClasificaciones();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _fetchClasificaciones() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/clasificaciones'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['clasificaciones'] as List<dynamic>;
      setState(() {
        _clasificaciones = items
            .map((e) => ClasificacionDenuncia.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al cargar las clasificaciones: ${response.reasonPhrase}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerClasificacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final body = json.encode({'nombre': _nombreController.text.trim()});
    final response = await http.post(
      Uri.parse('$apiBaseUrl/clasificaciones'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: body,
    );

    if (response.statusCode == 201) {
      _nombreController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clasificación registrada correctamente')),
      );
      await _fetchClasificaciones();
    } else {
      String errorMsg;
      try {
        final err = json.decode(response.body);
        errorMsg = err['error'] ?? response.reasonPhrase!;
      } catch (_) {
        errorMsg = response.reasonPhrase ?? 'Error desconocido';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al registrar clasificación: $errorMsg')),
      );
    }

    setState(() => _isSaving = false);
  }

  Future<void> _deleteClasificacion(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final response = await http.delete(
      Uri.parse('$apiBaseUrl/clasificaciones/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clasificación eliminada correctamente')),
      );
      await _fetchClasificaciones();
    } else {
      String errorMsg;
      try {
        final err = json.decode(response.body);
        errorMsg = err['error'] ?? response.reasonPhrase!;
      } catch (_) {
        errorMsg = response.reasonPhrase ?? 'Error desconocido';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al eliminar clasificación: $errorMsg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Clasificaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Clasificación',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty
                                  ? 'Ingrese el nombre de la clasificación'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              _isSaving ? null : _registerClasificacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Registrar Clasificación',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Clasificaciones Registradas',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _clasificaciones.isEmpty
                        ? const Center(
                            child: Text('No hay clasificaciones registradas.'))
                        : ListView.builder(
                            itemCount: _clasificaciones.length,
                            itemBuilder: (context, index) {
                              final c = _clasificaciones[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(c.nombre),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _deleteClasificacion(c.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
