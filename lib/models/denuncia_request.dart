import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DenunciaRequest {
  final String descripcion;
  final String fecha;             
  final String? hora;               
  final int clasificacionId;
  final int? otraClasificacionId;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  final List<File> imagenes;     

  DenunciaRequest({
    required this.descripcion,
    required this.fecha,
    this.hora,
    required this.clasificacionId,
    this.otraClasificacionId,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
    this.imagenes = const [],
  });

  Future<http.StreamedResponse> send(String token, String apiBaseUrl) async {
    final uri = Uri.parse('$apiBaseUrl/denuncias');
    final req = http.MultipartRequest('POST', uri);

    req.headers['Authorization'] = 'Bearer $token';
    req.headers['Content-Type'] = 'multipart/form-data';

    req.fields['descripcion'] = descripcion;
    req.fields['fecha'] = fecha;
    if (hora != null) {
      req.fields['hora'] = hora!;
    }
    req.fields['clasificacion_id'] = clasificacionId.toString();
    if (otraClasificacionId != null) {
      req.fields['otra_clasificacion_id'] = otraClasificacionId.toString();
    }
    req.fields['ubicacion_latitud'] = ubicacionLatitud.toString();
    req.fields['ubicacion_longitud'] = ubicacionLongitud.toString();

    for (var file in imagenes) {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final parts = mimeType.split('/');
      req.files.add(
        await http.MultipartFile.fromPath(
          'imagenes',
          file.path,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    }

    return req.send();
  }
}
