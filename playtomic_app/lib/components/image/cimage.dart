import 'package:flutter/material.dart';
import 'package:playtomic_app/components/image/cimagestyle.dart';

enum ImageStyle { DEFAULT,ROUND, ROUND_SHADOW, SHADOW, }

class CImage extends StatelessWidget {
  final ImageStyle style;
  final String imagePath;
  final double width;
  final double height;

  const CImage({super.key, required this.style, required this.imagePath, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    CImageStyle.setStyle(style);
    
    return Container(
      decoration:BoxDecoration(
        // Default style decoration
        borderRadius: CImageStyle.borderRadius,
         boxShadow: [
            BoxShadow(
              color: CImageStyle.shadowColor,
              spreadRadius: CImageStyle.spreadRadius,
              blurRadius: CImageStyle.blurRadius,
              offset: CImageStyle.shadowOffset,
            ),
          ],
      ),
      width: width,
      height: height,
        child: ClipRRect(
         borderRadius: CImageStyle.borderRadius,
          child: image()
          ),
    );
  }

  Widget image(){
    if(imagePath.contains("http")){
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
      );
    }
    else{
      return Image.asset(
        imagePath,
        
        fit: BoxFit.cover,
      );
    }
  }

}