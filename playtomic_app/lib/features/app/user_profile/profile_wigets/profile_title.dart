
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:playtomic_app/components/image/cimage.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment:CrossAxisAlignment.start,
          children:[
              CImage(
                imagePath: "evil.jpg",
                style: ImageStyle.ROUND_SHADOW,
                width: 100,
                height: 100,
              ),
              SizedBox(
                width: 30,
              ),
              Column(
  children: [
    Text(
      "Nameeeeeeeeeeeeeeeeeeee",
      style: TextStyle(fontSize: 30),
    ),
    Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        "curantly at, is from",
        style: TextStyle(fontSize: 18),
      ),
    ),
  ],
),         
],
);
}


} 