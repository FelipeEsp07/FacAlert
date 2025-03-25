class Usuario {
  final int? id;
  final String nombre;
  final String email;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
  });

  // Convierte una instancia de Usuario a un Map para guardarlo en la BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
    };
  }

  // Crea una instancia de Usuario a partir de un Map (por ejemplo, al leer de la BD)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
    );
  }
}
