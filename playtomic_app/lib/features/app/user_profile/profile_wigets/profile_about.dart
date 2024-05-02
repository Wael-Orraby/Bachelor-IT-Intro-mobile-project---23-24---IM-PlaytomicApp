import 'package:flutter/material.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';
import 'package:playtomic_app/components/button/cbutton.dart';
import 'package:playtomic_app/features/app/user_profile/UserData.dart';

class ProfileAbout extends StatefulWidget {
  const ProfileAbout({super.key});

  @override
   State<ProfileAbout> createState() => _ProfileAboutState();
}

class _ProfileAboutState extends State<ProfileAbout> {
  late final ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeTotaalPlayed();
  }

  Future<void> _initializeTotaalPlayed() async {
    if(UserData.fetchFields == false) {
        loading = false;
        return;
    }
    await UserData.getUserFields().then((_) {
      print("Fields loaded");
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading

    ?  Container(
        margin: EdgeInsets.only(top: 
        MediaQuery.of(context).size.height/2 - kToolbarHeight *3),
        child: const Center(
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
      )
        : Expanded(
            child: ListView.builder(
              itemCount: UserData.userFieldsList?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Field field = UserData.userFieldsList![index];
                return Stack(
                  children: [
                    FieldListItem(
                      field: field,
                      selectedDay: _selectedDay,
                    ),
                    Positioned(
                      top: 20,
                      left: 15,
                      child: CButton(
                        style: ButtonType.DARK,
                        onPressed: () async {
                          // Set current game to the selected field
                          UserData.currentGame = field;
                          await UserData.saveData();
                          print(field.name);
                          Navigator.pushNamed(context, "/profile");
                        },
                        text: "Play",
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }
}
