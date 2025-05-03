import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class Role {
  final int id;
  final String nombre;

  Role({required this.id, required this.nombre});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

class GestionRolesScreen extends StatefulWidget {
  const GestionRolesScreen({Key? key}) : super(key: key);

  @override
  State<GestionRolesScreen> createState() => _GestionRolesScreenState();
}

class _GestionRolesScreenState extends State<GestionRolesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roleController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  late final String apiBaseUrl;
  List<Role> roles = [];

  @override
  void initState() {
    super.initState();
    apiBaseUrl = Config.apiBase;
    _fetchRoles();
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoles() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/roles'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rolesJson = data['roles'] as List<dynamic>;
      setState(() {
        roles = rolesJson.map((e) => Role.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los roles: ${response.reasonPhrase}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerRole() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final body = json.encode({'nombre': _roleController.text.trim()});
    final response = await http.post(
      Uri.parse('$apiBaseUrl/roles'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
    );

    if (response.statusCode == 201) {
      _roleController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol registrado correctamente')),
      );
      await _fetchRoles();
    } else {
      String errorMsg;
      try {
        final err = json.decode(response.body);
        errorMsg = err['error'] ?? response.reasonPhrase!;
      } catch (_) {
        errorMsg = response.reasonPhrase ?? 'Error desconocido';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar rol: $errorMsg')),
      );
    }

    setState(() => _isSaving = false);
  }

  Future<void> _deleteRole(int roleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    final response = await http.delete(
      Uri.parse('$apiBaseUrl/roles/$roleId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol eliminado correctamente')),
      );
      await _fetchRoles();
    } else {
      String errorMsg;
      try {
        final err = json.decode(response.body);
        errorMsg = err['error'] ?? response.reasonPhrase!;
      } catch (_) {
        errorMsg = response.reasonPhrase ?? 'Error desconocido';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar rol: $errorMsg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Roles',
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
                          controller: _roleController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Rol',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Ingrese el nombre del rol'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _registerRole,
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
                                  'Registrar Rol',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Roles Registrados',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: roles.isEmpty
                        ? const Center(child: Text('No hay roles registrados.'))
                        : ListView.builder(
                            itemCount: roles.length,
                            itemBuilder: (context, index) {
                              final role = roles[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(role.nombre),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteRole(role.id),
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
