import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../config.dart';
import '../models/registration_admin_request.dart';
import '../models/role_model.dart';

class RegistroAdminScreen extends StatefulWidget {
  const RegistroAdminScreen({super.key});

  @override
  State<RegistroAdminScreen> createState() => _RegistroAdminScreenState();
}

class _RegistroAdminScreenState extends State<RegistroAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nombre': TextEditingController(),
    'cedula': TextEditingController(),
    'telefono': TextEditingController(),
    'direccion': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };
  int? _selectedRoleId;
  bool _isLoading = false;
  bool _isFetchingRoles = true;
  List<Role> _roles = [];
  final Dio _dio = Dio(BaseOptions(baseUrl: Config.apiBase));
  final Color _verde = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchRoles() async {
    setState(() => _isFetchingRoles = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    try {
      final response = await _dio.get(
        '/roles',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode == 200) {
        final rolesJson = (response.data['roles'] as List);
        setState(() {
          _roles = rolesJson.map((e) => Role.fromJson(e)).toList();
        });
      }
    } catch (e) {
      _showMessage('Error al cargar roles: $e');
    } finally {
      setState(() => _isFetchingRoles = false);
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() != true || _isLoading) return;
    if (_selectedRoleId == null) {
      _showMessage('Debes seleccionar un rol.');
      return;
    }

    final pwd = _controllers['password']!.text.trim();
    final confirmPwd = _controllers['confirmPassword']!.text.trim();
    if (pwd != confirmPwd) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }

    final request = RegistrationAdminRequest(
      nombre: _controllers['nombre']!.text.trim(),
      cedula: _controllers['cedula']!.text.trim(),
      telefono: _controllers['telefono']!.text.trim(),
      direccion: _controllers['direccion']!.text.trim(),
      email: _controllers['email']!.text.trim(),
      password: pwd,
      rolId: _selectedRoleId!,
      latitud: 0.0,
      longitud: 0.0,
    );

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/iniciar');
      return;
    }

    try {
      final response = await _dio.post(
        '/usuarios',
        data: request.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showMessage('Usuario registrado exitosamente.', success: true);
        Navigator.pop(context);
      } else {
        final msg = response.data['error'] ?? 'Error: ${response.statusCode}';
        _showMessage(msg);
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    final color = success ? _verde : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        title: const Text('Registro de Usuarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _controllers['nombre']!,
                        label: 'Nombre',
                        icon: Icons.person,
                        validator: (v) => _validateField(v, 'el nombre'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _controllers['cedula']!,
                        label: 'Cédula',
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
                        validator: (v) => _validateField(v, 'la cédula'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _controllers['telefono']!,
                        label: 'Teléfono',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => _validateField(v, 'el teléfono'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _controllers['direccion']!,
                        label: 'Dirección',
                        icon: Icons.home,
                        validator: (v) => _validateField(v, 'la dirección'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _controllers['email']!,
                        label: 'Correo Electrónico',
                        icon: Icons.email,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _controllers['password']!,
                        label: 'Contraseña',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _controllers['confirmPassword']!,
                        label: 'Confirmar Contraseña',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 24),
                      _isFetchingRoles
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                              value: _selectedRoleId,
                              decoration: InputDecoration(
                                hintText: 'Seleccionar Rol',
                                prefixIcon: Icon(Icons.admin_panel_settings, color: _verde),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem<int>(
                                  value: role.id,
                                  child: Text(role.nombre),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedRoleId = value),
                              validator: (value) => value == null ? 'Seleccione un rol.' : null,
                            ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Crear Cuenta',
                        onPressed: _register,
                        backgroundColor: _verde,
                        textColor: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese $fieldName.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese el correo.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la contraseña.';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }
}
