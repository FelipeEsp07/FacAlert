import 'package:flutter/material.dart';

class ReclasificarDenunciaScreen extends StatefulWidget {
  final Map<String, String> denuncia;

  const ReclasificarDenunciaScreen({super.key, required this.denuncia});

  @override
  State<ReclasificarDenunciaScreen> createState() => _ReclasificarDenunciaScreenState();
}

class _ReclasificarDenunciaScreenState extends State<ReclasificarDenunciaScreen> {
  String? _nuevaClasificacion;
  final List<String> _clasificaciones = ['Robo', 'Vandalismo', 'Acoso', 'Accidente', 'Otro'];

  void _guardarReclasificacion() {
    if (_nuevaClasificacion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Denuncia reclasificada como $_nuevaClasificacion.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una nueva clasificación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Reclasificar Denuncia',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.denuncia['titulo']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Seleccione una nueva clasificación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _nuevaClasificacion,
              items: _clasificaciones
                  .map((clasificacion) => DropdownMenuItem(
                        value: clasificacion,
                        child: Text(clasificacion),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _nuevaClasificacion = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Seleccione una clasificación',
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _guardarReclasificacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
