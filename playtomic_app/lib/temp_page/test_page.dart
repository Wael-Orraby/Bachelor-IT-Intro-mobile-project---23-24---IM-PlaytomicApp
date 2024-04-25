import 'package:flutter/material.dart';
import 'package:playtomic_app/components/button/cbutton.dart';
import 'package:playtomic_app/components/image/cimage.dart';
import '../components/text_field/ctext_field.dart';

class TestPage extends StatelessWidget {
  static final TextEditingController myController = TextEditingController();

  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              CTextField(
                style: TextFieldStyle.DARK,
                labelText: 'Enerfwertgt',
                controller: myController,
              ),
              CButton(
                style: ButtonType.SECONDARY,
                text: "text",
                onPressed: () {
                  print(myController.text);
                }
              ),
              const CImage(
                style: ImageStyle.DEFAULT, 
                imagePath: 'evil.jpg', 
                width: 200, height: 200
                ),
            ],
          ),
        ),
      ),
    );
  }
}