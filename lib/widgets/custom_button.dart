import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey.shade300;
    final fgColor = textColor ?? Colors.black;
    final radius = borderRadius ?? BorderRadius.circular(100);
    final pad = padding ?? const EdgeInsets.symmetric(vertical: 14);
    final elev = elevation ?? 2.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: bgColor,
        borderRadius: radius,
        elevation: elev,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Padding(
            padding: pad,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Verdana',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: fgColor,
                  letterSpacing: 0.1,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
