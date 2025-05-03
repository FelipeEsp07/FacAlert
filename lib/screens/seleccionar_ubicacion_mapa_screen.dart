import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SeleccionarUbicacionMapaScreen extends StatefulWidget {
  final LatLng ubicacionInicial;

  const SeleccionarUbicacionMapaScreen({super.key, required this.ubicacionInicial});

  @override
  State<SeleccionarUbicacionMapaScreen> createState() => _SeleccionarUbicacionMapaScreenState();
}

class _SeleccionarUbicacionMapaScreenState extends State<SeleccionarUbicacionMapaScreen> {
  LatLng? _ubicacionSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.ubicacionInicial,
          zoom: 15,
        ),
        onTap: (LatLng ubicacion) {
          setState(() {
            _ubicacionSeleccionada = ubicacion;
          });
        },
        markers: _ubicacionSeleccionada != null
            ? {
                Marker(
                  markerId: const MarkerId('ubicacion_seleccionada'),
                  position: _ubicacionSeleccionada!,
                ),
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _ubicacionSeleccionada);
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
