class ClasificacionDenuncia {
  final int id;
  final String nombre;

  ClasificacionDenuncia({required this.id, required this.nombre});

  factory ClasificacionDenuncia.fromJson(Map<String, dynamic> json) {
    return ClasificacionDenuncia(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}
