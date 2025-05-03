import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipPath(
                    clipper: ArcClipper(),
                    child: SizedBox(
                      height: 300,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/sapo.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.white.withOpacity(0.6)),
                          Image.asset(
                            'assets/images/facalert_logo.png',
                            width: 250,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Bienvenido a la plataforma de denuncias ciudadanas para Facatativá, Cundinamarca',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Verdana',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Iniciar Sesión',
                          onPressed: () => Navigator.pushNamed(context, '/iniciar'),
                          backgroundColor: theme.colorScheme.primary,
                          textColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Registrarse',
                          onPressed: () => Navigator.pushNamed(context, '/registro'),
                          backgroundColor: theme.colorScheme.secondary,
                          textColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
