import 'package:flutter/material.dart';
import 'package:playtomic_app/components/button/cbutton.dart';
import 'package:playtomic_app/components/image/cimage.dart';
import 'package:playtomic_app/components/text_field/ctext_field.dart';
import 'package:playtomic_app/features/app/user_profile/MainUser.dart';

class ProfileTitle extends StatefulWidget {
  const ProfileTitle({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<ProfileTitle> createState() => _ProfileTitleState();
}

class _ProfileTitleState extends State<ProfileTitle> {
  final TextEditingController _textEditingController = TextEditingController();
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _initializeTotaalPlayed();
  }
  

    Future<void> _initializeTotaalPlayed() async {
    if(MainUser.fetchUser == false) {
      loading = false;
      return;
    }
    await MainUser.getUserFields();
    await MainUser.getMainUser().then((_) async {
      print(MainUser.userFieldsList!.length);
      loading = false;
      print(loading);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // IF LOADED IN
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.65),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!loading)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CImage(
                    imagePath: "evil.jpg",
                    style: ImageStyle.ROUND_SHADOW,
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MainUser.name ?? 'Unknown',
                        style: const TextStyle(fontSize: 30),
                      ),
                      Text(
                        "${MainUser.currentGame?.name ?? 'Unknown'}, ${MainUser.country ?? 'Unknown'}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            if (!loading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Totaal Games: ${MainUser.countTotaalPlayed()}",
                        style: const TextStyle(fontSize: 30),
                      ),
                      const Divider(color: Colors.black),
                    ],
                  ),
                ],
              ),
            if (loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            const Divider(color: Colors.black),
            Row(
              children: [
                CButton(
                  style: ButtonType.PRIMARY,
                  text: "Edit Profile",
                  onPressed: () => _showEditProfileDialog(context),
                ),
                const SizedBox(width: 10),
                CButton(
                  style: ButtonType.SECONDARY,
                  text: "Log Out",
                  onPressed: () {
                    MainUser.logOut();
                    Navigator.pushNamed(context, "/login");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: CTextField(
              style: TextFieldStyle.SECONDARY,
              labelText: MainUser.name ?? 'Unknown',
              controller: _textEditingController),
          actions: [
            CButton(
              style: ButtonType.RED,
              text: "Cancel",
              onPressed: () {
                Navigator.pop(context);
                _textEditingController.clear();
              },
            ),
            CButton(
              style: ButtonType.PRIMARY,
              text: "Save",
              onPressed: () {
                editProfile();
                Navigator.pop(context);
                _textEditingController.clear();
                MainUser.saveData();
              },
            ),
          ],
        );
      },
    );
  }

  void editProfile() {
    setState(() {
      MainUser.name = _textEditingController.text;
    });
    // Implement EditProfile functionality here
  }
}
