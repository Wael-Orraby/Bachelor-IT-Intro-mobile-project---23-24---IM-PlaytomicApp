import 'package:flutter/material.dart';

enum Style { DEFAULT, MODERN, VINTAGE }

class MyClass extends StatelessWidget {
  final Style style;
  final String image;
  final double width;
  final double height;

  MyClass({required this.style, required this.image, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getStyleDecoration(),
      width: width,
      height: height,
      child: Image.asset(
        image,
        fit: BoxFit.cover,
      ),
    );
  }

  BoxDecoration _getStyleDecoration() {
    switch (style) {
      case Style.DEFAULT:
        return BoxDecoration(
          // Default style decoration
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        );
      case Style.MODERN:
        return const BoxDecoration(
          // Modern style decoration
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case Style.VINTAGE:
        return BoxDecoration(
          // Vintage style decoration
          color: Colors.brown,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset:const Offset(0, 3),
            ),
          ],
        );
      default:
        return const BoxDecoration(); // Return an empty decoration for unknown styles
    }
  }
}