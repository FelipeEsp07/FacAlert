import 'package:flutter/material.dart';

class SupervisarDenunciasScreen extends StatelessWidget {
  const SupervisarDenunciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Supervisar Denuncias',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Text(
          'Aquí se supervisan las denuncias.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
