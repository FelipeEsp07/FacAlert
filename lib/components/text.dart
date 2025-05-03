import 'package:flutter/material.dart';

class TextExample extends StatelessWidget {
  const TextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Spacer(),
        Text("Hola mundo", style: TextStyle(fontSize: 30)),
        Spacer(),
        Text("Hola mundo", style: TextStyle(fontWeight: FontWeight.bold)),
        Spacer(),
      ],
    );
  }
}
