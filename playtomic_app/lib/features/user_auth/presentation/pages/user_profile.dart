// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:playtomic_app/features/app/user_profile/profile_wigets/profile_about.dart';
import 'package:playtomic_app/features/app/user_profile/profile_wigets/profile_title.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/navbar_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
    void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("User Account"),
        ),
      ),
      body: const Column(
        children: [
          ProfileTitle(),
          ProfileAbout(),
        ],
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }
}
