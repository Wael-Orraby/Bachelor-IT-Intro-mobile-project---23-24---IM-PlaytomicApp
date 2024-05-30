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

  @override
  void initState() {
    super.initState();
    _initializeTotaalPlayed();
  }

  Future<void> _initializeTotaalPlayed() async {
    print(MainUser.user.userName);
    await MainUser.getUserFields();
    await MainUser.getMainUser().then((_) async {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: MainUser.user.userFieldsList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Field field = MainUser.user.userFieldsList![index];
          return Stack(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Image.network(
                      field.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Location: ${field.location}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Start at: ${MainUser.user.userFieldTimerList![index]}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
