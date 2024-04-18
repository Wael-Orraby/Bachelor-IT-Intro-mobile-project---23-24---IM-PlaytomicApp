import 'package:flutter/material.dart';

enum ButtonType {
  PRIMARY,
  SECONDARY,
  DARK
}

class Button extends StatelessWidget{
  final ButtonType style;
  final String text; 
  final VoidCallback onPressed;

  // Constructor with a key parameter
  const Button({
    super.key,
    required this.style,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return createButton(style, text, onPressed);
  }

  static Widget createButton(ButtonType style, String text, VoidCallback onPressed) {
    Color buttonColor;
    Color textColor;

    switch (style) {
      case ButtonType.PRIMARY:
        buttonColor = Colors.blue;
        textColor = Colors.white;
        break;
      case ButtonType.SECONDARY:
        buttonColor = Colors.grey;
        textColor = Colors.black;
        break;
      case ButtonType.DARK:
        buttonColor = Colors.black;
        textColor = Colors.white;
        break;
    }
    // return
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
