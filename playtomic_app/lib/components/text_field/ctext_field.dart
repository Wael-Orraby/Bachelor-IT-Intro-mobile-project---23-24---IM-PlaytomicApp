import 'package:flutter/material.dart';
import 'package:playtomic_app/components/text_field/ctext_fieldstyle.dart';

enum TextFieldStyle {
  STANDARD,
  SECONDARY,
  DARK,
}

class CTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController controller;
  final TextFieldStyle style;

  const CTextField({
    super.key,
    required this.style,
    required this.labelText,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    CTextFieldStyle.setStyle(style);
    return createButton(labelText, controller, obscureText);
  }

  static Widget createButton(String labelText, TextEditingController controller, bool obscureText) {
    TextStyle textStyle = CTextFieldStyle.textStyle;
    Color focusedBorderColor = CTextFieldStyle.focusedBorderColor;
    Color enabledBorderColor = CTextFieldStyle.enabledBorderColor;
    Color textFieldBackgroundColor = CTextFieldStyle.textFieldBackgroundColor;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: textStyle,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: textStyle.color),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: focusedBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor),
        ),
        filled: true,
        fillColor: textFieldBackgroundColor,
      ),
    );
  }
}
