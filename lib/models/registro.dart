class RegistrationRequest {
  final String nombre;
  final String cedula;
  final String telefono;
  final String direccion;
  final String email;
  final String password;
  final double latitud;  
  final double longitud;  

  RegistrationRequest({
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    required this.email,
    required this.password,
    required this.latitud,  
    required this.longitud,  
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cedula': cedula,
        'telefono': telefono,
        'direccion': direccion,
        'email': email,
        'password': password,
        'latitud': latitud,     
        'longitud': longitud,   
      };
}