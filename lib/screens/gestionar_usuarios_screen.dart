import 'package:flutter/material.dart';

class GestionarUsuariosScreen extends StatelessWidget {
  const GestionarUsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Gestionar Usuarios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Text(
          'Aquí se gestionan los usuarios.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
