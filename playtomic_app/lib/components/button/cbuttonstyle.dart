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
    }
  }

}