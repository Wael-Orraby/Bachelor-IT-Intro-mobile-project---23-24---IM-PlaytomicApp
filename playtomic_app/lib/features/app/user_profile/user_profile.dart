import 'package:flutter/material.dart';
import 'package:playtomic_app/components/image/cimage.dart';
import 'package:playtomic_app/features/app/user_profile/profile_wigets/profile_about.dart';
import 'package:playtomic_app/features/app/user_profile/profile_wigets/profile_title.dart';


class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("User Account"),
        ),
       body: const Column(
  children: [
    ProfileTitle(),
    ProfileAbout(),
  ],
),

    );
  }
}
