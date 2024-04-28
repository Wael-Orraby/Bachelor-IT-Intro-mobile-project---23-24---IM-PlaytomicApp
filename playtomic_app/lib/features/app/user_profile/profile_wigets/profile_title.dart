
import 'package:flutter/material.dart';
import 'package:playtomic_app/components/image/cimage.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const IntrinsicHeight(
      child: Column( 
        children: [ Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CImage(
            imagePath: "evil.jpg",
            style: ImageStyle.ROUND_SHADOW,
            width: 100,
            height: 100,
          ),
          SizedBox(
            width:30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nameeeeeeeeeeeeeee",
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "Currently at, is from",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ],
      )
    ]),
    ),
  );
}

}