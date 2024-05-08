import 'package:flutter/material.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';
import 'package:playtomic_app/components/button/cbutton.dart';
import 'package:playtomic_app/features/app/user_profile/MainUser.dart';

class ProfileAbout extends StatefulWidget {
  const ProfileAbout({super.key});

  @override
   State<ProfileAbout> createState() => _ProfileAboutState();
}

class _ProfileAboutState extends State<ProfileAbout> {
  late ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());
  bool loading = false;

  @override
  void initState() {
    super.initState();
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
              itemCount: MainUser.userFieldsList?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Field field = MainUser.userFieldsList![index];
                return Stack(
                  children: [
                    FieldListItem(
                      field: field,
                      selectedDay: _selectedDay,
                    ),
                  ],
                );
              },
            ),
          );
  }
}
