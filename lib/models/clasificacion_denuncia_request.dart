class ClasificacionDenunciaRequest {
  final String nombre;

  ClasificacionDenunciaRequest({
    required this.nombre,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
      };
}