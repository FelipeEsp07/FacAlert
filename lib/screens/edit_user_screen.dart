import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config.dart';
import '../models/usuario.dart';

class EditUserScreen extends StatefulWidget {
  final Usuario? usuario;
  final bool esAdmin;

  const EditUserScreen({
    Key? key,
    this.usuario,
    this.esAdmin = false,
  }) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreC;
  late final TextEditingController _cedulaC;
  late final TextEditingController _telefonoC;
  late final TextEditingController _direccionC;
  late final TextEditingController _emailC;

  bool _isActive = true;
  bool _isLoading = false;
  bool _saving = false;

  LatLng _currentPosition = const LatLng(4.8312, -74.3545);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _nombreC = TextEditingController();
    _cedulaC = TextEditingController();
    _telefonoC = TextEditingController();
    _direccionC = TextEditingController();
    _emailC = TextEditingController();

    if (widget.esAdmin) {
      _populateFromUsuario(widget.usuario!);
    } else {
      _fetchProfile();
    }
  }

  void _populateFromUsuario(Usuario u) {
    _nombreC.text = u.nombre;
    _cedulaC.text = u.cedula;
    _telefonoC.text = u.telefono;
    _direccionC.text = u.direccion;
    _emailC.text = u.email;
    _isActive = u.isActive;
    if (u.latitud != null && u.longitud != null) {
      _currentPosition = LatLng(u.latitud!, u.longitud!);
    }
  }

  @override
  void dispose() {
    _nombreC.dispose();
    _cedulaC.dispose();
    _telefonoC.dispose();
    _direccionC.dispose();
    _emailC.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/iniciar');
        return;
      }

      final res = await http.get(
        Uri.parse('${Config.apiBase}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final uMap = data['usuario'] as Map<String, dynamic>;
        final u = Usuario.fromJson(uMap);
        _populateFromUsuario(u);
      } else {
        _showSnackBar('Error al cargar perfil: ${res.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('Ocurrió un error al cargar el perfil.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final token = await _getToken();
      if (token == null) throw 'Sin token de sesión';

      Uri url;
      final body = {
        'nombre': _nombreC.text.trim(),
        'cedula': _cedulaC.text.trim(),
        'email': _emailC.text.trim(),
        'telefono': _telefonoC.text.trim(),
        'direccion': _direccionC.text.trim(),
        'latitud': _currentPosition.latitude,
        'longitud': _currentPosition.longitude,
      };

      if (widget.esAdmin) {
        final id = widget.usuario!.id;
        url = Uri.parse('${Config.apiBase}/usuarios/$id');
        body['is_active'] = _isActive;
      } else {
        url = Uri.parse('${Config.apiBase}/profile/edit');
      }

      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (res.statusCode == 200) {
        if (!widget.esAdmin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_nombre', _nombreC.text.trim());
          await prefs.setString('user_email', _emailC.text.trim());
          await prefs.setDouble('user_latitud', _currentPosition.latitude);
          await prefs.setDouble('user_longitud', _currentPosition.longitude);
        }
        _showSnackBar('Guardado exitoso');
        Navigator.pop(context, true);
      } else {
        final err = json.decode(res.body);
        throw 'Error ${res.statusCode}: ${err['error'] ?? res.reasonPhrase}';
      }
    } catch (e) {
      _showSnackBar('No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _mapController = ctrl;
    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: requiredField
            ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
            : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green[700]),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.green.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.esAdmin ? 'Editar Usuario' : 'Mi Perfil',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nombreC,
                label: 'Nombre',
                icon: Icons.person,
                requiredField: true,
              ),
              _buildTextField(
                controller: _cedulaC,
                label: 'Cédula',
                icon: Icons.badge,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _emailC,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                requiredField: true,
              ),
              _buildTextField(
                controller: _telefonoC,
                label: 'Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _direccionC,
                label: 'Dirección',
                icon: Icons.home,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ubicación en el mapa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('user_location'),
                        position: _currentPosition,
                        draggable: true,
                        onDragEnd: (pos) =>
                            setState(() => _currentPosition = pos),
                      ),
                    },
                    onTap: (pos) =>
                        setState(() => _currentPosition = pos),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (widget.esAdmin)
                SwitchListTile(
                  title: const Text('Activo',
                      style: TextStyle(fontSize: 16)),
                  value: _isActive,
                  activeColor: Colors.green,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              const SizedBox(height: 20),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        widget.esAdmin
                            ? 'Guardar Cambios'
                            : 'Actualizar Perfil',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.green[700],
                        elevation: 5,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
