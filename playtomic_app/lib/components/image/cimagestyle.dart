import 'package:flutter/material.dart';
import 'package:playtomic_app/components/image/cimage.dart';
// color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 5,
//             blurRadius: 7,
//             offset: Offset(0, 3)
class CImageStyle{

  static Color shadowColor = Colors.transparent;
  static double shadowOpacity = 0;
  static double blurRadius = 0;
  static double spreadRadius = 0;
  static Offset shadowOffset = const Offset(0, 0);
  static BorderRadius borderRadius = BorderRadius.circular(0);

  static void setStyle(ImageStyle style){
    switch (style) {
      case ImageStyle.DEFAULT:
        restStyle();
        break;
      case ImageStyle.ROUND:
        restStyle();
        borderRadius = BorderRadius.circular(180);
        break;
      case ImageStyle.ROUND_SHADOW:
        restStyle();
        borderRadius = BorderRadius.circular(100);
        setShadow(Colors.black, 0.5, 5,3, const Offset(0, 3));
        break;
      case ImageStyle.SHADOW:
        setShadow(Colors.black, 0.5, 5,3, const Offset(0, 3));
        break;
    }
  }

static void setShadow(Color color, double opacity, double radius, double spreadRadius, Offset offset) {
  shadowColor = color;
  shadowOpacity = opacity;
  blurRadius = radius;
  shadowOffset = offset;
}
  static void restStyle(){
    shadowColor = Colors.transparent;
    shadowOpacity = 0;
    blurRadius = 0;
    shadowOffset = const Offset(0, 0);
    borderRadius = BorderRadius.circular(0);
  }

}