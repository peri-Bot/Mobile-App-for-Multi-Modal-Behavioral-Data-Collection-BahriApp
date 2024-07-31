import 'package:flutter/material.dart';

class LogoCircularBorder extends StatelessWidget {
  final double widthfactor;
  const LogoCircularBorder({super.key, required this.widthfactor});
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthfactor,
      child: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
