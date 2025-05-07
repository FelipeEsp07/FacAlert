import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/denuncia.dart';

class DetalleDenunciaScreen extends StatefulWidget {
  final Denuncia denuncia;

  const DetalleDenunciaScreen({Key? key, required this.denuncia})
      : super(key: key);

  @override
  _DetalleDenunciaScreenState createState() => _DetalleDenunciaScreenState();
}

class _DetalleDenunciaScreenState extends State<DetalleDenunciaScreen> {
  late final LatLng _position;

  @override
  void initState() {
    super.initState();
    _position = LatLng(
      widget.denuncia.ubicacionLatitud,
      widget.denuncia.ubicacionLongitud,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(_position, 16),
    );
  }

  Future<void> _showSensitiveWarning(BuildContext context, String url) async {
    bool revealImage = false;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Contenido delicado',
      barrierColor: Colors.transparent,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: revealImage
                        ? GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.white,
                              ),
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility_off,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Contenido delicado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  'Esta foto incluye contenido delicado que algunas personas pueden encontrar ofensivo o molesto.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    setState(() => revealImage = true),
                                child: const Text(
                                  'Ver Foto',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.denuncia;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de Denuncia',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del Usuario
            const Text(
              'Información del Usuario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nombre: ${d.usuarioNombre}', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Cédula: ${d.usuarioCedula}', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Teléfono: ${d.usuarioTelefono}', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Email: ${d.usuarioEmail}', style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),

            // Descripción
            const Text(
              'Descripción:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(d.descripcion, style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),

            // Clasificación
            const Text(
              'Clasificación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(d.clasificacion?.nombre ?? '-', style: const TextStyle(fontSize: 15)),
            if (d.otraClasificacion != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Otra clasificación:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(d.otraClasificacion!.nombre, style: const TextStyle(fontSize: 15)),
            ],
            const Divider(height: 24),

            // Fecha y hora
            const Text(
              'Fecha y hora:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${d.fecha}${d.hora != null ? ' ${d.hora}' : ''}', style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),

            // Mapa
            const Text(
              'Ubicación en el mapa:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(target: _position, zoom: 16),
                  markers: {
                    Marker(
                      markerId: const MarkerId('denuncia_location'),
                      position: _position,
                    )
                  },
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
            const Divider(height: 24),

            // Imágenes
            if (d.imagenes.isNotEmpty) ...[
              const Text(
                'Imágenes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: d.imagenes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final url = d.imagenes[i];
                    return GestureDetector(
                      onTap: () => _showSensitiveWarning(context, url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.network(
                              url,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 60),
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                            ),
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(color: Colors.black.withOpacity(0)),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.black.withOpacity(0.4),
                                child: const Icon(
                                  Icons.visibility_off,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
