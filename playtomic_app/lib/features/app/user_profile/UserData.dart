
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class UserData {
  static String userId = '58YcDYkUOffFpnZZQujlof85VYB3';
  static String name = 'jeff';
  static String email = 'Bzzer@example.com';
  static String country = 'Netherlands';
  // FIELDS ID's
  static Field? curantGame;
  static int totalGames = 0;
  static List<Field>? userFieldsList;

     CollectionReference reservationsCollection = FirebaseFirestore.instance.collection('reservations');
    CollectionReference fieldsCollection = FirebaseFirestore.instance.collection('fields');

  static Future<bool> getUserFields() async {
    //GET DATA
    CollectionReference reservationsCollection = FirebaseFirestore.instance.collection('reservations');
    CollectionReference fieldsCollection = FirebaseFirestore.instance.collection('fields');

     // Count documents in collections
    QuerySnapshot reservationsSnapshot = await reservationsCollection.get();

       List<Field> fields = [];

    // Iterate through reservations
    for (QueryDocumentSnapshot reservation in reservationsSnapshot.docs) {
      String fieldId = reservation['fieldId'];
      // Get the corresponding field
      DocumentSnapshot fieldSnapshot =
          await fieldsCollection.doc(fieldId).get();
      if (fieldSnapshot.exists) {
        fields.add(Field.fromSnapshot(fieldSnapshot));
      }
    }
    print('user data has been catched user:$userId');
    userFieldsList = fields;
    return true;
  }

  static int countTotaalPlayed() {
    if (userFieldsList == null) return 0;

    return userFieldsList!.length;
  }
}