import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import '../models/usuario.dart';
import '../screens/edit_user_screen.dart';

class ListaUsuariosScreen extends StatefulWidget {
  const ListaUsuariosScreen({Key? key}) : super(key: key);

  @override
  State<ListaUsuariosScreen> createState() => _ListaUsuariosScreenState();
}

class _ListaUsuariosScreenState extends State<ListaUsuariosScreen> {
  bool _loading = true;
  List<Usuario> _usuarios = [];
  List<Usuario> _filteredUsuarios = [];
  String _searchQuery = '';
  final String apiBaseUrl = Config.apiBase;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      if (token == null) throw 'No se encontró el token de sesión';
      final res = await http.get(
        Uri.parse('$apiBaseUrl/usuarios'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['usuarios'] as List;
        final fetchedUsuarios = data.map((e) => Usuario.fromJson(e)).toList();
        setState(() {
          _usuarios = fetchedUsuarios;
          _filteredUsuarios = fetchedUsuarios;
        });
      } else {
        throw 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pude cargar usuarios: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsuarios = _usuarios.where((user) {
        return user.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteUser(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw 'No se encontró el token de sesión';
      final res = await http.delete(
        Uri.parse('$apiBaseUrl/usuarios/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado')),
        );
        await _fetchUsers();
      } else {
        throw 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pude eliminar usuario: $e')),
      );
    }
  }

  Future<void> _confirmDeleteUser(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: const Text(
            '¿Estás seguro que quieres eliminar este usuario? Esta acción no se puede deshacer.'),
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
      await _deleteUser(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            const Text('Lista de Usuarios', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : _filteredUsuarios.isEmpty
                    ? const Center(
                        child: Text('No hay usuarios que coincidan.',
                            style: TextStyle(fontSize: 16)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: _filteredUsuarios.length,
                        itemBuilder: (context, i) {
                          final u = _filteredUsuarios[i];
                          return Hero(
                            tag: 'user_${u.id}',
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
                                  child: const Icon(Icons.person,
                                      color: Colors.green, size: 30),
                                ),
                                title: Text(
                                  u.nombre,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${u.email}\n${u.rol?.nombre ?? "Sin rol"}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _iconButtonCircle(
                                      icon: Icons.edit,
                                      iconColor: Colors.blue,
                                      bgColor: Colors.blue[50]!,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditUserScreen(
                                              usuario: u,
                                              esAdmin: true,  // <-- flag corregido
                                            ),
                                          ),
                                        ).then((_) => _fetchUsers());
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _iconButtonCircle(
                                      icon: Icons.delete,
                                      iconColor: Colors.red,
                                      bgColor: Colors.red[50]!,
                                      onTap: () => _confirmDeleteUser(u.id),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar usuario por nombre...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.green[50],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            _searchQuery = value;
            _filterUsers();
          },
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
    return CircleAvatar(
      backgroundColor: bgColor,
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onTap,
      ),
    );
  }
}
