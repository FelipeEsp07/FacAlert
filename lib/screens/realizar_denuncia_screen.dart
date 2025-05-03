import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/denuncia_request.dart';
import '../models/clasificacion_denuncia.dart';
import 'seleccionar_ubicacion_mapa_screen.dart';

class RealizarDenunciaScreen extends StatefulWidget {
  const RealizarDenunciaScreen({super.key});

  @override
  State<RealizarDenunciaScreen> createState() => _RealizarDenunciaScreenState();
}

class _RealizarDenunciaScreenState extends State<RealizarDenunciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  List<ClasificacionDenuncia> _clasificaciones = [];
  ClasificacionDenuncia? _clasificacionSeleccionada;
  ClasificacionDenuncia? _otraClasificacionSeleccionada;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  final List<File> _imagenesSeleccionadas = [];
  LatLng? _ubicacionSeleccionada;

  bool _isLoading = false;
  bool _loadingClas = true;

  @override
  void initState() {
    super.initState();
    _fetchClasificaciones();
  }

  Future<void> _fetchClasificaciones() async {
    setState(() => _loadingClas = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final uri = Uri.parse('${Config.apiBase}/clasificaciones');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final list = (data['clasificaciones'] as List)
            .map((j) => ClasificacionDenuncia.fromJson(j))
            .toList();
        setState(() => _clasificaciones = list);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando clasificaciones')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _loadingClas = false);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaSeleccionada = fecha);
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) setState(() => _horaSeleccionada = hora);
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) setState(() => _imagenesSeleccionadas.add(File(imagen.path)));
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera);
    if (foto != null) setState(() => _imagenesSeleccionadas.add(File(foto.path)));
  }

  void _eliminarImagen(int index) {
    setState(() => _imagenesSeleccionadas.removeAt(index));
  }

  Future<void> _seleccionarUbicacionEnMapa() async {
    final ubicacion = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarUbicacionMapaScreen(
          ubicacionInicial: _ubicacionSeleccionada ??
              const LatLng(4.828903865120192, -74.3552112579438),
        ),
      ),
    );
    if (ubicacion != null) {
      setState(() {
        _ubicacionSeleccionada = ubicacion;
        _ubicacionController.text =
            '${ubicacion.latitude}, ${ubicacion.longitude}';
      });
    }
  }

  Future<void> _enviarDenuncia() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_clasificacionSeleccionada == _otraClasificacionSeleccionada &&
        _otraClasificacionSeleccionada != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La clasificación y la otra clasificación no pueden ser iguales.')),
      );
      return;
    }
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione la fecha.')));
      return;
    }
    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione la hora.')));
      return;
    }
    if (_ubicacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione la ubicación.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fechaStr =
          DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);
      final horaStr =
          '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}';

      final request = DenunciaRequest(
        descripcion: _descripcionController.text.trim(),
        fecha: fechaStr,
        hora: horaStr,
        clasificacionId: _clasificacionSeleccionada!.id,
        otraClasificacionId: _otraClasificacionSeleccionada?.id,
        ubicacionLatitud: _ubicacionSeleccionada!.latitude,
        ubicacionLongitud: _ubicacionSeleccionada!.longitude,
        imagenes: _imagenesSeleccionadas,
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final streamed = await request.send(token, Config.apiBase);
      final response = await http.Response.fromStream(streamed);
      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Denuncia creada correctamente.')));
        Navigator.pop(context, true);
      } else {
        final error = body['error'] ?? 'Error al crear la denuncia.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingClas) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Denuncia',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clasificación principal
                const Text('Clasificación de la Denuncia',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<ClasificacionDenuncia>(
                  value: _clasificacionSeleccionada,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Seleccione una clasificación'),
                  items: _clasificaciones
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _clasificacionSeleccionada = v),
                  validator: (v) =>
                      v == null ? 'Seleccione una clasificación' : null,
                ),

                const SizedBox(height: 16),
                // Otra clasificación
                const Text('¿Otra clasificación?',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<ClasificacionDenuncia>(
                  value: _otraClasificacionSeleccionada,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Otra clasificación (opcional)'),
                  items: _clasificaciones
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _otraClasificacionSeleccionada = v),
                  validator: (v) => v != null && v == _clasificacionSeleccionada
                      ? 'No puede ser igual'
                      : null,
                ),

                const SizedBox(height: 16),
                // Descripción
                const Text('Descripción',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Describa lo ocurrido'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'La descripción es obligatoria'
                      : null,
                ),

                const SizedBox(height: 16),
                // Ubicación
                const Text('Ubicación',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ubicacionController,
                  readOnly: true,
                  onTap: _seleccionarUbicacionEnMapa,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Seleccione la ubicación'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'La ubicación es obligatoria'
                      : null,
                ),

                const SizedBox(height: 16),
                // Fecha y hora
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _seleccionarFecha,
                            child: Text(
                              _fechaSeleccionada == null
                                  ? 'Seleccionar Fecha'
                                  : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                              style:
                                  const TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _seleccionarHora,
                            child: Text(
                              _horaSeleccionada == null
                                  ? 'Seleccionar Hora'
                                  : '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}',
                              style:
                                  const TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Imágenes
                const Text('Imágenes (opcional)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _seleccionarImagen,
                      icon: const Icon(Icons.photo_library,
                          color: Colors.white),
                      label: const Text('Seleccionar Imagen',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _tomarFoto,
                      icon:
                          const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('Tomar Foto',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),

                if (_imagenesSeleccionadas.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _imagenesSeleccionadas.length,
                      (i) => Stack(
                        children: [
                          Image.file(_imagenesSeleccionadas[i],
                              width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _eliminarImagen(i),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child:
                                    Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Text(
                  'Nota: Las denuncias realizadas aquí no reemplazan las denuncias formales ante la Fiscalía.',
                  style: TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic, color: Colors.red),
                ),

                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _enviarDenuncia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Enviar Denuncia',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
