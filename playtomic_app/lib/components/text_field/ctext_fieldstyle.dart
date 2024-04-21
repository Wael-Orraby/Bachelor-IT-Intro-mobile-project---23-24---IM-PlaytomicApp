import 'package:flutter/material.dart';
import 'package:playtomic_app/components/text_field/ctext_field.dart';

class CTextFieldStyle{
    static TextStyle textStyle = const TextStyle(color: Colors.black);
    static Color focusedBorderColor = Colors.white;
    static Color enabledBorderColor = Colors.white;
    static Color textFieldBackgroundColor = Colors.white;
  static void setStyle(TextFieldStyle style){
   switch (style) {
      case TextFieldStyle.STANDARD:
        textStyle = const TextStyle(color: Colors.black); // Adjust as needed
        focusedBorderColor = const Color.fromARGB(255, 55, 55, 55); // Adjust as needed
        enabledBorderColor = const Color.fromARGB(255, 87, 87, 87); // Adjust as needed
        break;
      case TextFieldStyle.SECONDARY:
        textStyle = const TextStyle(color: Colors.blue); // Adjust as needed
        focusedBorderColor = const Color.fromARGB(255, 116, 194, 118); // Adjust as needed
        enabledBorderColor = Colors.green; // Adjust as needed
        break;
      case TextFieldStyle.DARK:
        textStyle = const TextStyle(color: Colors.white); // Adjust as needed
        textFieldBackgroundColor = Colors.black;
        focusedBorderColor = Colors.grey; // Adjust as needed
        enabledBorderColor = Colors.grey; // Adjust as needed
        break;
    }
  }

}