// lib/models/imagen_denuncia.dart
class ImagenDenuncia {
  final int id;
  final String url;

  ImagenDenuncia({
    required this.id,
    required this.url,
  });

  factory ImagenDenuncia.fromJson(Map<String, dynamic> json) {
    return ImagenDenuncia(
      id: json['id'] as int,
      url: json['url'] as String,
    );
  }
}