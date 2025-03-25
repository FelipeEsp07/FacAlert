import 'package:flutter/material.dart';
import 'vistas/login.dart';
import 'vistas/registro.dart';
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
      initialRoute: '/registro',
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
      },
    );
  }
}
