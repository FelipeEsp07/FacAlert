import 'clasificacion_denuncia.dart';

class Denuncia {
  final int id;
  final String descripcion;
  final String fecha;   
  final String? hora;   
  final ClasificacionDenuncia? clasificacion;
  final ClasificacionDenuncia? otraClasificacion;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  final List<String> imagenes;

  Denuncia({
    required this.id,
    required this.descripcion,
    required this.fecha,
    this.hora,
    this.clasificacion,
    this.otraClasificacion,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
    required this.imagenes,
  });

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    ClasificacionDenuncia? _parseClas(Map<String, dynamic>? j) =>
        j != null ? ClasificacionDenuncia.fromJson(j) : null;

    return Denuncia(
      id: json['id'] as int,
      descripcion: json['descripcion'] as String,
      fecha: json['fecha'] as String,
      hora: json['hora'] as String?,
      clasificacion: _parseClas(
          json['clasificacion'] is Map ? json['clasificacion'] as Map<String, dynamic> : null),
      otraClasificacion: _parseClas(
          json['otra_clasificacion'] is Map ? json['otra_clasificacion'] as Map<String, dynamic> : null),
      ubicacionLatitud: (json['ubicacion_latitud'] as num).toDouble(),
      ubicacionLongitud: (json['ubicacion_longitud'] as num).toDouble(),
      imagenes: (json['imagenes'] as List<dynamic>).cast<String>(),
    );
  }
}
