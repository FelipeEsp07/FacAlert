// lib/models/cluster.dart

class Cluster {
  final double lat;
  final double lng;
  final int cantidad;
  final String tipoComun;

  Cluster({
    required this.lat,
    required this.lng,
    required this.cantidad,
    required this.tipoComun,
  });

  factory Cluster.fromJson(Map<String, dynamic> json) {
    return Cluster(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
      tipoComun: json['tipo_comun'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'cantidad': cantidad,
    'tipo_comun': tipoComun,
  };
}
