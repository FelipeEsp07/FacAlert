class Usuario {
  final int id;
  final String nombre;
  final String cedula;
  final String telefono;
  final String direccion;
  final String email;
  final String fechaRegistro;
  final bool isActive;
  final double? latitud;
  final double? longitud;
  final Rol? rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    required this.email,
    required this.fechaRegistro,
    required this.isActive,
    this.latitud,
    this.longitud,
    this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    Rol? rol;
    final rolJson = json['rol'];
    if (rolJson != null) {
      if (rolJson is Map<String, dynamic>) {
        rol = Rol.fromJson(rolJson);
      } else if (rolJson is String) {
        rol = Rol(id: 0, nombre: rolJson);
      }
    }

    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      cedula: json['cedula'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      email: json['email'] as String,
      fechaRegistro: json['fecha_registro'] as String,
      isActive: json['is_active'] as bool,
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
      rol: rol,
    );
  }
}

class Rol {
  final int id;
  final String nombre;

  Rol({
    required this.id,
    required this.nombre,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}
