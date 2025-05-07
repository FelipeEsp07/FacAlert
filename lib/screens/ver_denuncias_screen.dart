import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import '../models/denuncia.dart';
import '../screens/edit_denuncia_screen.dart';

class VerDenunciasScreen extends StatefulWidget {
  const VerDenunciasScreen({Key? key}) : super(key: key);

  @override
  State<VerDenunciasScreen> createState() => _VerDenunciasScreenState();
}

class _VerDenunciasScreenState extends State<VerDenunciasScreen> {
  bool _loading = false;
  List<Denuncia> _denuncias = [];
  List<Denuncia> _filteredDenuncias = [];
  final String apiBaseUrl = Config.apiBase;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);

    // 1. Leer email del usuario logueado
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email');
    if (_userEmail == null) {
      _showError('Usuario no autenticado');
      setState(() => _loading = false);
      return;
    }

    // 2. Cargar denuncias
    await _fetchDenuncias();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchDenuncias() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'No autenticado';

      final res = await http.get(
        Uri.parse('$apiBaseUrl/denuncias'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        throw 'Error ${res.statusCode}: ${res.body}';
      }

      final data = json.decode(res.body)['denuncias'] as List<dynamic>;
      final all = data.map((e) => Denuncia.fromJson(e)).toList();

      // Filtrar solo las denuncias del usuario según email
      final mine = all
          .where((d) => d.usuarioEmail.toLowerCase() == _userEmail!.toLowerCase())
          .toList();

      setState(() {
        _denuncias = mine;
        _filteredDenuncias = mine;
      });
    } catch (e) {
      _showError('No pude cargar denuncias: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
        content: const Text('Esta acción no se puede deshacer.'),
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
      if (token == null) throw 'No autenticado';

      final res = await http.delete(
        Uri.parse('$apiBaseUrl/denuncias/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        throw 'Error ${res.statusCode}: ${res.body}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denuncia eliminada')),
      );
      await _fetchDenuncias();
    } catch (e) {
      _showError('No pude eliminar denuncia: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Denuncias'),
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDenuncias,
        child: Column(
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: _filterDenuncias,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    )
                  : _filteredDenuncias.isEmpty
                      ? const Center(
                          child: Text(
                            'No tienes denuncias registradas.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemCount: _filteredDenuncias.length,
                          itemBuilder: (context, i) {
                            final d = _filteredDenuncias[i];
                            return Hero(
                              tag: 'denuncia_${d.id}',
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                shadowColor: Colors.black26,
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: d.status == 'APPROVED'
                                        ? const Color.fromARGB(
                                            255, 212, 255, 212)
                                        : const Color.fromARGB(
                                            255, 255, 212, 212),
                                    child: Icon(
                                      d.status == 'APPROVED'
                                          ? Icons.check_circle
                                          : Icons.report_problem,
                                      color: d.status == 'APPROVED'
                                          ? Colors.green
                                          : Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                  title: Text(
                                    d.descripcion,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Clasificación: ${d.clasificacion?.nombre ?? '-'}\n'
                                    'Fecha y hora: ${d.fecha} ${d.hora ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54),
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _iconButtonCircle(
                                        icon: Icons.edit,
                                        iconColor: Colors.orange,
                                        bgColor: Colors.orange[50]!,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditDenunciaScreen(
                                                denuncia: d,
                                              ),
                                            ),
                                          ).then((_) => _fetchDenuncias());
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _iconButtonCircle(
                                        icon: Icons.delete,
                                        iconColor: Colors.red,
                                        bgColor: Colors.red[50]!,
                                        onTap: () =>
                                            _confirmDeleteDenuncia(d.id),
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
      ),
    );
  }

  Widget _iconButtonCircle({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        iconSize: 16,
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
