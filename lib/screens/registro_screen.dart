import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/registro.dart';
import '../config.dart';
import '../widgets/map_picker_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _controllers = {
    'nombre': TextEditingController(),
    'cedula': TextEditingController(),
    'telefono': TextEditingController(),
    'direccion': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  double? _latitud;
  double? _longitud;

  final Dio _dio = Dio(BaseOptions(baseUrl: Config.apiBase));

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final initial = LatLng(4.8176, -74.3542); // Facatativá
    final LatLng? pos = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialPosition: initial),
      ),
    );
    if (pos != null) {
      setState(() {
        _latitud = pos.latitude;
        _longitud = pos.longitude;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitud == null || _longitud == null) {
      _showMessage('Debes seleccionar tu ubicación en el mapa.');
      return;
    }

    final pwd = _controllers['password']!.text.trim();
    final confirm = _controllers['confirmPassword']!.text.trim();
    if (pwd != confirm) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }

    try {
      final data = RegistrationRequest(
        nombre: _controllers['nombre']!.text.trim(),
        cedula: _controllers['cedula']!.text.trim(),
        telefono: _controllers['telefono']!.text.trim(),
        direccion: _controllers['direccion']!.text.trim(),
        email: _controllers['email']!.text.trim(),
        password: pwd,
        latitud: _latitud!,
        longitud: _longitud!,
      );

      final response = await _dio.post('/register', data: data.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage('Cuenta creada exitosamente.', success: true);
        Navigator.pushReplacementNamed(context, '/inicio');
      } else {
        _showMessage('Error al crear la cuenta.');
      }
    } catch (e) {
      _showMessage('Error de conexión: ${e.toString()}');
    }
  }

  void _showMessage(String message, {bool success = false}) {
    final color = success ? Colors.green : Colors.red;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  String? _validateField(String? value, String name) =>
      (value == null || value.trim().isEmpty)
          ? 'Por favor ingrese $name.'
          : null;

  String? _validateEmail(String? value) {
    final pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (value == null || value.trim().isEmpty) return 'Por favor ingrese el correo.';
    if (!RegExp(pattern).hasMatch(value)) return 'Ingrese un correo válido.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Por favor ingrese la contraseña.';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F1F6).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontFamily: 'Verdana',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.15,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Completa los campos para registrarte.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Verdana',
                              fontSize: 14,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
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
                          ElevatedButton.icon(
                            onPressed: _pickLocation,
                            icon: const Icon(Icons.location_on),
                            label: Text(
                              _latitud == null
                                  ? 'Elegir ubicación de hogar'
                                  : 'Ubicación: ${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)}',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: 'Crear Cuenta',
                            onPressed: _register,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            textColor: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
