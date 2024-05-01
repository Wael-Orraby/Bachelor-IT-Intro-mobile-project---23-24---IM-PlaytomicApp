
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:playtomic_app/components/image/cimage.dart';

class ProfileAbout extends StatefulWidget {
  const ProfileAbout({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<ProfileAbout> createState() => _ProfileAboutState();

}

class _ProfileAboutState extends State<ProfileAbout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const <Widget>[
          Text(style: TextStyle(fontSize: 20),  "Title 1"),
          SizedBox(
            height: 500,
            child: CImage(
              style: ImageStyle.DEFAULT,
              imagePath: "evil.jpg",
              width: double.infinity,
              height: 500,
            ),
          ),
          SizedBox(
            height: 500,
            child: CImage(
              style: ImageStyle.DEFAULT,
              imagePath: "evil.jpg",
              width: double.infinity,
              height: 500,
            ),
          ),  
        ],
      ),
    );
  }
}
