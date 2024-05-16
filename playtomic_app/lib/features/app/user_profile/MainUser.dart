
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtomic_app/features/app/user_profile/UserData.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class MainUser {
  static UserData user = UserData();

  // FIELDS ID's
  static Field? currentGame;
  static String? currentGameId;
  static Future<void> getUserFields() async {
    await user.getUserFields();
  }

  static Future<void> getMainUser() async {
    getUserFields();
    await user.getUser();
  }
//MABY NEED TO BE EDITED

  static void logOut() {
    clearUser();
    FirebaseAuth.instance.signOut();
    print("loged out");
  }

  static void clearUser() {
   user.clearUser();
  }

  static int countTotaalPlayed() {
    if (user.userFieldsList == null) return 0;
    return user.userFieldsList!.length;
  }
}
