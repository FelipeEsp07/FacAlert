import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BaseDeDatos {
  static Database? _database;
  BaseDeDatos._privateConstructor();
  static final BaseDeDatos instance = BaseDeDatos._privateConstructor();

  // Método para obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _iniciarBaseDeDatos();
    return _database!;
  }

  // Método para abrir la base de datos
  Future<Database> _iniciarBaseDeDatos() async {
    final rutaBD = await getDatabasesPath();
    final ruta = join(rutaBD, 'FacAlert.db');

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        print('La base de datos FacAlert creada.');
      },
      onOpen: (db) async {
        print('Base de datos FacAlert abierta.');
      },
    );
  }
}
