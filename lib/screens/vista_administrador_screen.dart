import 'package:flutter/material.dart';
import 'supervisar_denuncias_screen.dart';
import 'gestionar_usuarios_screen.dart';
import 'generar_informes_screen.dart';

class VistaAdministradorScreen extends StatelessWidget {
  const VistaAdministradorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Vista Administrador',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Denuncias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupervisarDenunciasScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.report, color: Colors.red, size: 28), // Red icon for reports
              label: const Text(
                'Supervisar Denuncias',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // White text
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // More rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24), // Increased padding
                elevation: 8, // Add shadow for depth
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GestionarUsuariosScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.people, color: Colors.blue, size: 28), // Blue icon for user management
              label: const Text(
                'Gestionar Usuarios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // White text
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // More rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24), // Increased padding
                elevation: 8, // Add shadow for depth
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Generar Informes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenerarInformesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart, color: Colors.orange, size: 28), // Orange icon for reports
              label: const Text(
                'Generar Informes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // White text
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // More rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24), // Increased padding
                elevation: 8, // Add shadow for depth
              ),
            ),
          ],
        ),
      ),
    );
  }
}
