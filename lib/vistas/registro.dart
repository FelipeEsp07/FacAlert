import 'package:flutter/material.dart';
import 'package:fac_alert/modelos/usuario.dart';
import 'package:fac_alert/database/usuario_dao.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  final UsuarioDao _usuarioDao = UsuarioDao();

  // Método para registrar usuario
  void _registrarUsuario() async {
    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    final usuario = Usuario(
      nombre: _nombreController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      cedula: _cedulaController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
    );

    final resultado = await _usuarioDao.crearUsuario(usuario);
    if (resultado > 0) {
      _mostrarMensaje('Registro exitoso');
      Navigator.pop(context);
    } else {
      _mostrarMensaje('Error al registrar usuario');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorFondoStart = const Color(0xFFB2DFDB);
    final colorFondoEnd = const Color(0xFFE0F2F1);
    final colorBoton = const Color(0xFF00796B);
    final colorTextoCampos = const Color(0xFF004D40);
    final colorTitulo = const Color(0xFF00695C);
    final colorSubtitulo = const Color(0xFF00897B);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorFondoStart, colorFondoEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Text(
                'FacAlert',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorTitulo,
                  letterSpacing: 1.2,
                  fontFamily: 'Cursive',
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: colorTitulo,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea una nueva cuenta',
                style: TextStyle(
                  fontSize: 16,
                  color: colorSubtitulo,
                ),
              ),
              const SizedBox(height: 40),

              // Nombre Completo
              _campoTexto('Nombre Completo', Icons.person, _nombreController, TextInputType.name),

              // Correo Electrónico
              _campoTexto('Correo', Icons.email, _correoController, TextInputType.emailAddress),

              // Teléfono
              _campoTexto('Teléfono', Icons.phone, _telefonoController, TextInputType.phone),

              // Dirección
              _campoTexto('Dirección', Icons.location_on, _direccionController, TextInputType.streetAddress),

              // Cédula
              _campoTexto('Cédula', Icons.badge, _cedulaController, TextInputType.number),

              // Contraseña
              _campoTexto('Contraseña', Icons.lock, _contrasenaController, TextInputType.visiblePassword, esContrasena: true),

              // Confirmar Contraseña
              _campoTexto('Confirmar Contraseña', Icons.lock_outline, _confirmarContrasenaController, TextInputType.visiblePassword, esContrasena: true),

              const SizedBox(height: 30),

              // Botón "Registrarse"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _registrarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorBoton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black38,
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para crear campos de texto reutilizables
  Widget _campoTexto(
      String hintText,
      IconData icon,
      TextEditingController controller,
      TextInputType tipo,
      {bool esContrasena = false}
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        obscureText: esContrasena,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF004D40).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF004D40)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cedulaController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}
