// lib/models/cluster.dart

class Cluster {
  final double lat;
  final double lng;
  final int cantidad;
  final String tipoComun;

  // Nuevos campos
  final Map<String,int> delitos;         // conteo por tipo de delito
  final Map<int,int> hourHistogram;      // histograma hora → cantidad
  final List<DangerSlot> dangerSlots;    // franjas críticas

  Cluster({
    required this.lat,
    required this.lng,
    required this.cantidad,
    required this.tipoComun,
    required this.delitos,
    required this.hourHistogram,
    required this.dangerSlots,
  });

  factory Cluster.fromJson(Map<String, dynamic> json) {
    // Parseo de 'delitos'
    final delitosMap = <String,int>{};
    if (json['delitos'] is Map) {
      (json['delitos'] as Map<String,dynamic>).forEach((k,v) {
        delitosMap[k] = (v as num).toInt();
      });
    }

    // Parseo de 'hour_histogram' como int→int
    final histMap = <int,int>{};
    if (json['hour_histogram'] is Map) {
      (json['hour_histogram'] as Map<String,dynamic>).forEach((k,v) {
        histMap[int.parse(k)] = (v as num).toInt();
      });
    }

    // Parseo de 'danger_slots' lista de objetos {start,end}
    final slots = <DangerSlot>[];
    if (json['danger_slots'] is List) {
      for (var item in json['danger_slots'] as List<dynamic>) {
        final m = item as Map<String,dynamic>;
        slots.add(DangerSlot(
          start: (m['start'] as num).toInt(),
          end:   (m['end']   as num).toInt(),
        ));
      }
    }

    return Cluster(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
      tipoComun: json['tipo_comun'] as String,
      delitos: delitosMap,
      hourHistogram: histMap,
      dangerSlots: slots,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'cantidad': cantidad,
    'tipo_comun': tipoComun,
    'delitos': delitos,
    'hour_histogram': hourHistogram.map((k,v) => MapEntry(k.toString(), v)),
    'danger_slots': dangerSlots.map((s) => s.toJson()).toList(),
  };
}

class DangerSlot {
  final int start;
  final int end;
  DangerSlot({ required this.start, required this.end });

  factory DangerSlot.fromJson(Map<String,dynamic> json) => DangerSlot(
    start: (json['start'] as num).toInt(),
    end:   (json['end']   as num).toInt(),
  );

  Map<String,int> toJson() => {
    'start': start,
    'end': end,
  };
}
