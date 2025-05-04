// lib/models/denuncia.dart
import 'clasificacion_denuncia.dart';

class Denuncia {
  final int id;
  final String descripcion;
  final String fecha;
  final String? hora;
  final ClasificacionDenuncia? clasificacion;
  final ClasificacionDenuncia? otraClasificacion;
  final String usuarioNombre;
  final String usuarioCedula;
  final String usuarioTelefono;
  final String usuarioEmail;
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
    required this.usuarioNombre,
    required this.usuarioCedula,
    required this.usuarioTelefono,
    required this.usuarioEmail,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
    required this.imagenes,
  });

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    ClasificacionDenuncia? _parseClas(dynamic j) =>
        j is Map<String, dynamic> ? ClasificacionDenuncia.fromJson(j) : null;

    final usuario = json['usuario'] as Map<String, dynamic>? ?? {};

    return Denuncia(
      id: json['id'] as int,
      descripcion: json['descripcion'] as String,
      fecha: json['fecha'] as String,
      hora: json['hora'] as String?,
      clasificacion: _parseClas(json['clasificacion']),
      otraClasificacion: _parseClas(json['otra_clasificacion']),
      usuarioNombre: usuario['nombre'] as String? ?? '—',
      usuarioCedula: usuario['cedula'] as String? ?? '',
      usuarioTelefono: usuario['telefono'] as String? ?? '',
      usuarioEmail: usuario['email'] as String? ?? '',
      ubicacionLatitud: (json['ubicacion_latitud'] as num).toDouble(),
      ubicacionLongitud: (json['ubicacion_longitud'] as num).toDouble(),
      imagenes: (json['imagenes'] as List<dynamic>).cast<String>(),
    );
  }
}
