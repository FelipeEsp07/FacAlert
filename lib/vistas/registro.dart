import 'package:flutter/material.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de colores personalizados
    final Color colorFondoStart = const Color(0xFFB2DFDB);
    final Color colorFondoEnd = const Color(0xFFE0F2F1);
    final Color colorBoton = const Color(0xFF00796B);
    final Color colorTextoCampos = const Color(0xFF004D40);
    final Color colorTitulo = const Color(0xFF00695C);
    final Color colorSubtitulo = const Color(0xFF00897B);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título de la app
                Text(
                  'FacAlert',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorTitulo,
                    letterSpacing: 1.2,
                    fontFamily: 'Cursive', // Agrega la fuente en pubspec.yaml si la usas
                  ),
                ),
                const SizedBox(height: 30),

                // Título de la pantalla de registro
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

                // Campo para el Nombre Completo
                Container(
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
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Nombre Completo',
                      hintStyle: TextStyle(color: colorTextoCampos.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.person, color: colorTextoCampos),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para el Correo
                Container(
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
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Correo',
                      hintStyle: TextStyle(color: colorTextoCampos.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.email, color: colorTextoCampos),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para la Contraseña
                Container(
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
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: colorTextoCampos.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.lock, color: colorTextoCampos),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para Confirmar la Contraseña
                Container(
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
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirmar Contraseña',
                      hintStyle: TextStyle(color: colorTextoCampos.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.lock_outline, color: colorTextoCampos),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón "Registrarse"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica para registrarse
                    },
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
                const SizedBox(height: 20),

                // Separador para métodos alternativos
                Text(
                  'O regístrate con',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorTextoCampos,
                  ),
                ),
                const SizedBox(height: 20),

                // Botones para redes sociales
                Column(
                  children: [
                    // Botón de Google
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para registrarse con Google
                        },
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Registrarse con Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón de Facebook
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para registrarse con Facebook
                        },
                        icon: const Icon(Icons.facebook, size: 24, color: Colors.white),
                        label: const Text('Registrarse con Facebook'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3b5998),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón de Twitter
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para registrarse con Twitter
                        },
                        icon: const Icon(Icons.alternate_email, size: 24, color: Colors.white),
                        label: const Text('Registrarse con Twitter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DA1F2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
