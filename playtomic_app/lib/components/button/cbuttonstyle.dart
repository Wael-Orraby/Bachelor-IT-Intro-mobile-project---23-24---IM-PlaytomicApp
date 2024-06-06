import 'package:flutter/material.dart';
import 'package:playtomic_app/components/button/cbutton.dart';

class CButtonStyle{

  static Color buttonColor = Colors.white;
  static Color textColor = Colors.white;
  static void setStyle(ButtonType style){
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
      case ButtonType.RED:
        buttonColor = Colors.red;
        textColor = Colors.white;
      case ButtonType.SECONDARY_BLUE:
        buttonColor = const Color.fromARGB(255, 189, 190, 190);
        textColor = const Color.fromARGB(255, 52, 71, 87);
      break;
      case ButtonType.LIGHTBLUE:
        buttonColor = const Color.fromARGB(255, 185, 214, 227);
        textColor = const Color.fromARGB(255, 67, 67, 67);
    }
  }

}