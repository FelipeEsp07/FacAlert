import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cluster.dart';

class ClusterService {
  final String baseUrl;
  final String token;

  ClusterService({ required this.baseUrl, required this.token });

  Future<List<Cluster>> fetchClusters({
    double radius = 75.0,
    int threshold = 3,    
  }) async {
    final uri = Uri.parse(
      '$baseUrl/denuncias/clusters/'
      '?radius=$radius&threshold=$threshold'
    );
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('Error al cargar clusters: ${resp.statusCode}');
    }
    final List data = jsonDecode(resp.body);
    return data.map((j) => Cluster.fromJson(j)).toList();
  }
}
