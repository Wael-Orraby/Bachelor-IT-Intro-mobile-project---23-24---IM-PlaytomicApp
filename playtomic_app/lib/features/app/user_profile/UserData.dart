
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class UserData {
  static String? userId = 'n3DEgoZvQVP2dSvtohA9pKjHqNo2';
  static String? email = "wael1@gmail.com";
  static String? name;
  static String? country;
  // FIELDS ID's
  static Field? currentGame;
  static List<Field>? userFieldsList; 
  

  static Future<void> getUserFields() async {
    //GET DATA
    CollectionReference? reservationsCollection = FirebaseFirestore.instance.collection('reservations');
    CollectionReference? fieldsCollection = FirebaseFirestore.instance.collection('fields');

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
    print('user data has been catched user: $userId');
    userFieldsList = fields;
  }

  static Future<void> getUserData() async {
    CollectionReference? userCollection = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await userCollection
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDataSnapshot = querySnapshot.docs.first;
      // Access the user data
      name = userDataSnapshot['username'];
      country = userDataSnapshot['country'];
      // You can update other UserData fields similarly
    } else {
      print('User not found');
    }
  }

  static void logOut(){
    clearUser();
    FirebaseAuth.instance.signOut();
    print("loged out");
  }

  static void clearUser(){
    userId = null;
    email = null;
    name = null;
    country = null;
    currentGame = null;
    userFieldsList = null;
  }

  static int countTotaalPlayed() {
    if (userFieldsList == null) return 0;
    return userFieldsList!.length;
  }
}