import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Color borderColor;
  final Color labelColor;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.borderColor,
    required this.labelColor,
    required this.labelText,
    this.obscureText = false,
        this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
