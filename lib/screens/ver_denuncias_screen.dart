import 'package:flutter/material.dart';
import 'detalle_denuncia_screen.dart'; // Importar la nueva pantalla de detalles

class VerDenunciasScreen extends StatelessWidget {
  const VerDenunciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> denuncias = [
      {'titulo': 'Robo en el parque', 'descripcion': 'Se reportó un robo en el parque central.'},
      {'titulo': 'Vandalismo en la escuela', 'descripcion': 'Pintadas en las paredes de la escuela.'},
      {'titulo': 'Accidente de tráfico', 'descripcion': 'Choque entre dos vehículos en la avenida principal.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Denuncias',
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
            ),
          );
        },
      ),
    );
  }
}
