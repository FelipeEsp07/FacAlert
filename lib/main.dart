import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'screens/inicio_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/iniciar_screen.dart';
import 'screens/main_screen.dart';
import 'screens/realizar_denuncia_screen.dart';
import 'screens/ver_denuncias_screen.dart';
import 'screens/moderador_denuncias_screen.dart';
import 'screens/vista_administrador_screen.dart';
import 'screens/supervisar_denuncias_screen.dart';
import 'screens/gestion_roles_screen.dart';
import 'screens/generar_informes_screen.dart';
import 'screens/seleccionar_ubicacion_mapa_screen.dart';
import 'screens/lista_usuarios_screen.dart';
import 'screens/gest_usuarios.dart';
import 'screens/registro_admin_screen.dart';

import 'models/usuario.dart';
import 'screens/edit_user_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FacAlert',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/inicio',
      routes: {
        '/': (context) => const IniciarScreen(),
        '/inicio': (context) => const InicioScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/iniciar': (context) => const IniciarScreen(),

        // Pantallas autenticadas
        '/main': (context) => const MainScreen(),

        // Perfil propio (usuario normal)
        '/perfil': (context) => const EditUserScreen(esAdmin: false),

        '/misDenuncias': (context) => const VerDenunciasScreen(),
        '/realizar_denuncia': (context) => const RealizarDenunciaScreen(),
        '/vistaModerador': (context) => const ModeradorDenunciasScreen(),
        '/vistaAdministrador': (context) => const VistaAdministradorScreen(),
        '/supervisarDenuncias': (context) => const SupervisarDenunciasScreen(),

        // Gestión de Usuarios
        '/gestUsuarios': (context) => const GestUsuariosScreen(),
        '/gestionUsuarios/registro': (context) => const RegistroAdminScreen(),
        '/gestionUsuarios/lista': (context) => const ListaUsuariosScreen(),
        '/gestionRoles': (context) => const GestionRolesScreen(),

        '/editarUsuario': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Usuario) {
            return EditUserScreen(usuario: args, esAdmin: true);
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('No se especificó el usuario a editar')),
          );
        },

        '/generarInformes': (context) => const GenerarInformesScreen(),
        '/seleccionarUbicacionMapa': (context) =>
            const SeleccionarUbicacionMapaScreen(
              ubicacionInicial: LatLng(4.828903865120192, -74.3552112579438),
            ),
      },
    );
  }
}
