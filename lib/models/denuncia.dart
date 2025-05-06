// lib/models/denuncia.dart
import 'clasificacion_denuncia.dart';

class Denuncia {
  final int id;
  final String descripcion;
  final String fecha;
  final String? hora;
  final ClasificacionDenuncia? clasificacion;
  final ClasificacionDenuncia? otraClasificacion;
  final String status;
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
    required this.status,
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
      // Evitar el error de null casteado a String:
      status: json['status'] as String? ?? 'PENDING',
      usuarioNombre: usuario['nombre'] as String? ?? '—',
      usuarioCedula: usuario['cedula'] as String? ?? '',
      usuarioTelefono: usuario['telefono'] as String? ?? '',
      usuarioEmail: usuario['email'] as String? ?? '',
      ubicacionLatitud: (json['ubicacion_latitud'] as num).toDouble(),
      ubicacionLongitud: (json['ubicacion_longitud'] as num).toDouble(),
      imagenes: (json['imagenes'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'fecha': fecha,
        'hora': hora,
        'clasificacion_id': clasificacion?.id,
        'otra_clasificacion_id': otraClasificacion?.id,
        'status': status,
        'usuario': {
          'nombre': usuarioNombre,
          'cedula': usuarioCedula,
          'telefono': usuarioTelefono,
          'email': usuarioEmail,
        },
        'ubicacion_latitud': ubicacionLatitud,
        'ubicacion_longitud': ubicacionLongitud,
        'imagenes': imagenes,
      };
}
