import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/detalle_denuncias_screen.dart';

import '../config.dart';
import '../models/denuncia.dart';

class ListaDenunciasScreen extends StatefulWidget {
  const ListaDenunciasScreen({Key? key}) : super(key: key);

  @override
  State<ListaDenunciasScreen> createState() => _ListaDenunciasScreenState();
}

class _ListaDenunciasScreenState extends State<ListaDenunciasScreen> {
  bool _loading = true;
  List<Denuncia> _denuncias = [];
  List<Denuncia> _filteredDenuncias = [];
  final String apiBaseUrl = Config.apiBase;

  @override
  void initState() {
    super.initState();
    _fetchDenuncias();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchDenuncias() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'No se encontró el token de sesión';

      final res = await http.get(
        Uri.parse('$apiBaseUrl/denuncias'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body)['denuncias'] as List;
        final fetched = data.map((e) => Denuncia.fromJson(e)).toList();
        setState(() {
          _denuncias = fetched;
          _filteredDenuncias = fetched;
        });
      } else {
        throw 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pude cargar denuncias: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterDenuncias(String query) {
    setState(() {
      _filteredDenuncias = _denuncias.where((d) {
        return d.descripcion.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _confirmDeleteDenuncia(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar denuncia?'),
        content: const Text(
          '¿Estás seguro que quieres eliminar esta denuncia? Esta acción no se puede deshacer.'
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteDenuncia(id);
    }
  }

  Future<void> _deleteDenuncia(int id) async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'No se encontró el token de sesión';

      final res = await http.delete(
        Uri.parse('$apiBaseUrl/denuncias/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denuncia eliminada')),
        );
        await _fetchDenuncias();
      } else {
        throw 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pude eliminar denuncia: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Denuncias'),
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por descripción...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.green[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _filterDenuncias,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : _filteredDenuncias.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay denuncias que coincidan.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: _filteredDenuncias.length,
                        itemBuilder: (context, i) {
                          final d = _filteredDenuncias[i];
                          return Hero(
                            tag: 'denuncia_${d.id}',
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              shadowColor: Colors.black26,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.green[100],
                                  child: const Icon(
                                    Icons.report_problem,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                                title: Text(
                                  d.descripcion,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Clasificación: ${d.clasificacion?.nombre ?? '-'}\n'
                                  'Usuario: ${d.usuarioNombre}\n'
                                  'Fecha y hora: ${d.fecha} ${d.hora ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _iconButtonCircle(
                                      icon: Icons.visibility,
                                      iconColor: Colors.blue,
                                      bgColor: Colors.blue[50]!,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetalleDenunciaScreen(denuncia: d),
                                            ),
                                          );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _iconButtonCircle(
                                      icon: Icons.delete,
                                      iconColor: Colors.red,
                                      bgColor: Colors.red[50]!,
                                      onTap: () => _confirmDeleteDenuncia(d.id),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _iconButtonCircle({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return CircleAvatar(
      backgroundColor: bgColor,
      child: IconButton(icon: Icon(icon, color: iconColor), onPressed: onTap),
    );
  }
}
