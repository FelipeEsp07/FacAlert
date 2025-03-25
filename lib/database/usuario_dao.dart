import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/base_de_datos.dart';
import '../modelos/usuario.dart';

class UsuarioDao {
  // Método para encriptar la contraseña usando SHA256
  String _encriptarContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Crear un nuevo usuario
  Future<int> crearUsuario(Usuario usuario) async {
    try {
      final db = await BaseDeDatos.instance.database;
      final usuarioEncriptado = usuario.copyWith(
        contrasena: _encriptarContrasena(usuario.contrasena),
      );

      int id = await db.insert(
        'usuarios',
        usuarioEncriptado.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Usuario creado con ID: $id');
      return id;
    } catch (e) {
      print('Error al crear usuario: $e');
      return -1;
    }
  }

  // Actualizar un usuario
  Future<int> actualizarUsuario(Usuario usuario) async {
    try {
      final db = await BaseDeDatos.instance.database;

      final usuarioEncriptado = usuario.copyWith(
        contrasena: _encriptarContrasena(usuario.contrasena),
      );

      int resultado = await db.update(
        'usuarios',
        usuarioEncriptado.toMap(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );

      if (resultado > 0) {
        print('Usuario actualizado correctamente.');
      } else {
        print('No se encontró el usuario para actualizar.');
      }

      return resultado;
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return -1;
    }
  }

  // Eliminar un usuario por ID
  Future<int> eliminarUsuario(int id) async {
    try {
      final db = await BaseDeDatos.instance.database;
      int resultado = await db.delete(
        'usuarios',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (resultado > 0) {
        print('Usuario eliminado correctamente.');
      } else {
        print('No se encontró el usuario para eliminar.');
      }

      return resultado;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return -1;
    }
  }

  // Obtener todos los usuarios
  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final db = await BaseDeDatos.instance.database;
      final List<Map<String, dynamic>> resultados = await db.query('usuarios');

      List<Usuario> listaUsuarios =
      resultados.map((mapa) => Usuario.fromMap(mapa)).toList();

      print('Se encontraron ${listaUsuarios.length} usuarios.');
      return listaUsuarios;
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }
}
