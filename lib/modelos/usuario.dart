import 'dart:convert';
import 'package:crypto/crypto.dart';

class Usuario {
  final int? id;
  final String nombre;
  final String correo;
  final String telefono;
  final String direccion;
  final String cedula;
  final String contrasena;

  Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.cedula,
    required this.contrasena,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'cedula': cedula,
      'contrasena': _encriptarContrasena(contrasena),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      cedula: map['cedula'],
      contrasena: map['contrasena'],
    );
  }

  // Método para encriptar la contraseña con SHA-256
  static String _encriptarContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? telefono,
    String? direccion,
    String? cedula,
    String? contrasena,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      cedula: cedula ?? this.cedula,
      contrasena: contrasena ?? this.contrasena,
    );
  }
}
