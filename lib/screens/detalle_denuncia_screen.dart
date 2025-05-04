import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 

class DetalleDenunciaScreen extends StatelessWidget {
  final Map<String, String> denuncia;

  const DetalleDenunciaScreen({super.key, required this.denuncia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Cambiar icono de devolver a blanco
        title: const Text(
          'Detalle de la Denuncia',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  denuncia['titulo']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32), // Color verde para el título
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  denuncia['descripcion']!,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Detalles adicionales:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.category, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Clasificación: Robo', // Ejemplo de clasificación
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Dirección:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  denuncia['direccion'] ?? 'Dirección no disponible',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ubicación en el mapa:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200, // Altura del mapa
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        double.parse(denuncia['latitud'] ?? '0.0'),
                        double.parse(denuncia['longitud'] ?? '0.0'),
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('ubicacion_denuncia'),
                        position: LatLng(
                          double.parse(denuncia['latitud'] ?? '0.0'),
                          double.parse(denuncia['longitud'] ?? '0.0'),
                        ),
                        infoWindow: InfoWindow(
                          title: denuncia['titulo'],
                          snippet: denuncia['direccion'],
                        ),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Eliminación'),
                          content: const Text('¿Está seguro de que desea eliminar esta denuncia?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), // Close dialog
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Logic to delete the complaint
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Return to the previous screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Denuncia eliminada correctamente')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Red color for delete action
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.white, size: 28), // Larger icon
                    label: const Text(
                      'Eliminar Denuncia',
                      style: TextStyle(color: Colors.white), // White text color
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red color for delete button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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