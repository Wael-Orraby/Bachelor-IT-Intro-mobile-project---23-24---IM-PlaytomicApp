
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class MainUser {
  static String? documentId;
  static String? userId; // 'n3DEgoZvQVP2dSvtohA9pKjHqNo2';
  static String? email; // "wael1@gmail.com";
  static String? name;
  static String? country;
  // FIELDS ID's
  static Field? currentGame;
  static String? currentGameId;
  static List<Field>? userFieldsList;
  static bool fetchUser = true;
  static bool fetchFields = true;
  static Future<void> getUserFields() async {
    if (!fetchFields) return;
    fetchFields = false;
    //GET DATA
    CollectionReference? reservationsCollection =
        FirebaseFirestore.instance.collection('reservations');
    CollectionReference? fieldsCollection =
        FirebaseFirestore.instance.collection('fields');

    // Count documents in collections
    QuerySnapshot reservationsSnapshot =
        await reservationsCollection.where('userId', isEqualTo: userId).get();

    List<Field> fields = [];
    DocumentSnapshot gameSnapshot = await fieldsCollection.doc(currentGameId).get();
    if(gameSnapshot.exists) {
      currentGame = Field.fromSnapshot(gameSnapshot);
    }

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

  static Future<void> getMainUser() async {
    if (!fetchUser) return;
    fetchUser = false;
    CollectionReference? userCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await userCollection.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot mainUserSnapshot = querySnapshot.docs.first;
      documentId = mainUserSnapshot.id;
      print(documentId);
      // Access the user data
      name = mainUserSnapshot['username'];
      country = mainUserSnapshot['country'];

      // You can update other MainUser fields similarly
    } else {
      print('User not found');
    }
  }
//MABY NEED TO BE EDITED
  static Future<void> saveData() async {
    if (name == null || email == null || currentGame == null) {
      print('Error: Some required data is null');
      return;
    }

    print("username: $name");
    print("email: $email");
    print("playing: ${currentGame!.name}");

    String? docId =
        documentId ?? FirebaseFirestore.instance.collection('users').doc().id;

    FirebaseFirestore.instance
        .collection('users') // Specify the collection
        .doc(docId) // Specify the document ID
        .set({
          'username': name,
          'country': country,
          'playing': currentGame!.documentId,
          'email': email,
        })
        .then((value) => print('Data saved successfully'))
        .catchError((error) => print('Failed to save data: $error'));
  }

  static void logOut() {
    clearUser();
    FirebaseAuth.instance.signOut();
    print("loged out");
  }

  static void clearUser() {
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
