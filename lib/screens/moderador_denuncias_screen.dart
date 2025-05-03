import 'package:flutter/material.dart';
import 'reclasificar_denuncia_screen.dart'; // Importar la pantalla de reclasificación

class ModeradorDenunciasScreen extends StatelessWidget {
  const ModeradorDenunciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> denuncias = [
      {'titulo': 'Robo en el parque', 'descripcion': 'Se reportó un robo en el parque central.', 'clasificacion': 'Robo'},
      {'titulo': 'Vandalismo en la escuela', 'descripcion': 'Pintadas en las paredes de la escuela.', 'clasificacion': 'Vandalismo'},
      {'titulo': 'Accidente de tráfico', 'descripcion': 'Choque entre dos vehículos en la avenida principal.', 'clasificacion': 'Accidente'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Supervisión de Denuncias',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: denuncias.length,
        itemBuilder: (context, index) {
          final denuncia = denuncias[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text(
                denuncia['titulo']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(denuncia['descripcion']!),
              leading: const Icon(Icons.report, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleDenunciaScreen(denuncia: denuncia),
                  ),
                );
              },
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Reclasificar') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReclasificarDenunciaScreen(denuncia: denuncia),
                      ),
                    );
                  } else if (value == 'Reportar Usuario') {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController motivoController = TextEditingController();
                        return AlertDialog(
                          title: const Text('Reportar Usuario'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Especifique el motivo del reporte:'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: motivoController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Ingrese el motivo',
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final motivo = motivoController.text.trim();
                                if (motivo.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Usuario reportado. Motivo: $motivo')),
                                  );
                                  Navigator.pop(context); // Cerrar el diálogo
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Debe especificar un motivo.')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                              ),
                              child: const Text('Reportar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Reclasificar',
                    child: Text('Reclasificar'),
                  ),
                  const PopupMenuItem(
                    value: 'Reportar Usuario',
                    child: Text('Reportar Usuario'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetalleDenunciaScreen extends StatelessWidget {
  final Map<String, String> denuncia;

  const DetalleDenunciaScreen({super.key, required this.denuncia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(denuncia['titulo']!),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(denuncia['descripcion']!),
            const SizedBox(height: 16),
            Text(
              'Clasificación:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(denuncia['clasificacion']!),
          ],
        ),
      ),
    );
  }
}
