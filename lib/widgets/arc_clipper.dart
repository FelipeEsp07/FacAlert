import 'package:flutter/widgets.dart';

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Start at the bottom-left
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point
      size.width, size.height - 50, // End point
    );
    path.lineTo(size.width, 0); // Top-right
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
