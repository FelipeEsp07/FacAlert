import 'package:flutter/material.dart';
import 'vistas/login.dart';     // Ajusta la ruta según la ubicación de tu archivo
import 'vistas/registro.dart';  // Ajusta la ruta según la ubicación de tu archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FacAlert',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/registro', // Pantalla inicial
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
      },
    );
  }
}
