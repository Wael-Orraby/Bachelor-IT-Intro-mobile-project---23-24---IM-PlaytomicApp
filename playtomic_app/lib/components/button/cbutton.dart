import 'package:flutter/material.dart';
import 'package:playtomic_app/components/button/cbuttonstyle.dart';

enum ButtonType {
  PRIMARY,
  SECONDARY,
  DARK,
  RED
}

class CButton extends StatelessWidget{
  final ButtonType style;
  final String text; 
  final VoidCallback onPressed;

  // Constructor with a key parameter
  const CButton({
    super.key,
    required this.style,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    CButtonStyle.setStyle(style);
    return createButton(style, text, onPressed);
  }

  static Widget createButton(ButtonType style, String text, VoidCallback onPressed) {
    Color buttonColor = CButtonStyle.buttonColor;
    Color textColor = CButtonStyle.textColor;
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
