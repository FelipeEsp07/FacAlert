class RegistrationAdminRequest {
  final String nombre;
  final String cedula;
  final String telefono;
  final String direccion;
  final String email;
  final String password;
  final int rolId;
  final double? latitud;
  final double? longitud;

  RegistrationAdminRequest({
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    required this.email,
    required this.password,
    required this.rolId,
    this.latitud,
    this.longitud,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cedula': cedula,
        'telefono': telefono,
        'direccion': direccion,
        'email': email,
        'password': password,
        'rol_id': rolId,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
      };
}