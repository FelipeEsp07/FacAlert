import 'package:flutter/material.dart';

class GenerarInformesScreen extends StatelessWidget {
  const GenerarInformesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Generar Informes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Text(
          'Aquí se generan los informes.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
