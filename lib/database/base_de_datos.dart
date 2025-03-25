import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Función para inicializar y abrir (o crear) la base de datos
Future<Database> iniciarBaseDeDatos() async {
  // Obtiene la ruta donde se guardarán las bases de datos en el dispositivo
  final rutaBD = await getDatabasesPath();
  final ruta = join(rutaBD, 'mi_base_de_datos.db');

  // Abre o crea la base de datos y define la estructura inicial
  return await openDatabase(
    ruta,
    version: 1,
    onCreate: (db, version) async {
      // Crea la tabla "usuarios"
      await db.execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          email TEXT
        )
      ''');
    },
  );
}