// lib/services/denuncia_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DenunciaService {
  final String apiBase;
  final String token;

  DenunciaService({
    required this.apiBase,
    required this.token,
  });

  /// [newStatus] debe ser 'APPROVED' o 'REJECTED'.
  Future<bool> changeStatus(int denunciaId, String newStatus) async {
    final uri = Uri.parse('$apiBase/denuncias/$denunciaId');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Error al cambiar estado de denuncia: ${response.statusCode} ${response.body}');
    }
  }
}
