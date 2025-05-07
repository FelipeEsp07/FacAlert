import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../models/denuncia.dart';

class EditDenunciaScreen extends StatefulWidget {
  final Denuncia denuncia;

  const EditDenunciaScreen({Key? key, required this.denuncia}) : super(key: key);

  @override
  _EditDenunciaScreenState createState() => _EditDenunciaScreenState();
}

class _EditDenunciaScreenState extends State<EditDenunciaScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descripcionC;
  late final TextEditingController _fechaC;
  late final TextEditingController _horaC;
  late LatLng _posicion;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  bool _saving = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final d = widget.denuncia;
    _descripcionC = TextEditingController(text: d.descripcion);
    _fechaC = TextEditingController(text: d.fecha);
    _horaC = TextEditingController(text: d.hora ?? '');
    _posicion = LatLng(d.ubicacionLatitud, d.ubicacionLongitud);

    // Parsear fecha/hora iniciales
    _fechaSeleccionada = DateTime.tryParse(d.fecha);
    if (d.hora != null && d.hora!.isNotEmpty) {
      final parts = d.hora!.split(':');
      _horaSeleccionada = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _descripcionC.dispose();
    _fechaC.dispose();
    _horaC.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _seleccionarHora() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horaSeleccionada = picked;
        // Formatear en AM/PM
        final dt = DateTime(0, 0, 0, picked.hour, picked.minute);
        _horaC.text = DateFormat.jm().format(dt); // e.g. "2:30 PM"
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _fechaC.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'Token no disponible';

      final url = Uri.parse('${Config.apiBase}/denuncias/${widget.denuncia.id}');
      final body = {
        'descripcion': _descripcionC.text.trim(),
        'fecha': _fechaC.text.trim(),
        'hora': _horaC.text.trim(),
        'ubicacion_latitud': _posicion.latitude,
        'ubicacion_longitud': _posicion.longitude,
      };

      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (res.statusCode == 200) {
        _showSnackBar('Denuncia actualizada con éxito.');
        Navigator.pop(context, true);
      } else {
        final err = json.decode(res.body);
        throw 'Error ${res.statusCode}: ${err['error'] ?? res.reasonPhrase}';
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _mapController = ctrl;
    _mapController?.animateCamera(CameraUpdate.newLatLng(_posicion));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        validator: requiredField
            ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
            : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Denuncia',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _descripcionC,
                label: 'Descripción',
                icon: Icons.description,
                requiredField: true,
              ),
              _buildTextField(
                controller: _fechaC,
                label: 'Fecha',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _seleccionarFecha,
                requiredField: true,
              ),
              _buildTextField(
                controller: _horaC,
                label: 'Hora',
                icon: Icons.access_time,
                readOnly: true,
                onTap: _seleccionarHora,
                requiredField: false,
              ),
              const SizedBox(height: 20),
              const Text('Ubicación de la denuncia',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition:
                        CameraPosition(target: _posicion, zoom: 15),
                    markers: {
                      Marker(
                        markerId: const MarkerId('ubicacion'),
                        position: _posicion,
                        draggable: true,
                        onDragEnd: (pos) => setState(() => _posicion = pos),
                      )
                    },
                    onTap: (pos) => setState(() => _posicion = pos),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _saving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Guardar Cambios',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
