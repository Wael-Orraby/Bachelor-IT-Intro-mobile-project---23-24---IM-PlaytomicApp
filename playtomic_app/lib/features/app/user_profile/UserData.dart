
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class UserData{
  String? documentId;
  String? userId; // 'n3DEgoZvQVP2dSvtohA9pKjHqNo2';
  String? email; // "wael1@gmail.com";
  String? userName;
  String? country;
  int? wins = 0;
  int? losses = 0;
  List<Field>? userFieldsList;
  List<String>? userFieldTimerList;
  List<String>? userReservationIdList;

  UserData({this.documentId, this.userId, this.email, this.userName, this.country, this.wins, this.losses});


  Future<void> getUserFields() async {
    //GET DATA
    print("getinging user fields: " + email!);
    CollectionReference? reservationsCollection =
        FirebaseFirestore.instance.collection('reservations');
    CollectionReference? fieldsCollection =
        FirebaseFirestore.instance.collection('fields');

    // Count documents in collections
    QuerySnapshot userReservationsSnapshot =
        await reservationsCollection.where('userId', isEqualTo: userId).get();

    List<Field> fields = [];
    List<String> timers = [];
    List<String> reservationIds = [];

    // Iterate through userReservations
    for (QueryDocumentSnapshot reservation in userReservationsSnapshot.docs) {
      String fieldId = reservation['fieldId'];
      // Get the corresponding field
      DocumentSnapshot fieldSnapshot =
          await fieldsCollection.doc(fieldId).get();
      if (fieldSnapshot.exists) {
        fields.add(Field.fromSnapshot(fieldSnapshot));
        timers.add(reservation['time'].toString());
        reservationIds.add(reservation.id);
      }
    }

    userFieldsList = fields;
    userFieldTimerList = timers;
    userReservationIdList = reservationIds;
    
    print(fields);
  }
   Future<void> getUser() async {
    CollectionReference? userCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await userCollection.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot mainUserSnapshot = querySnapshot.docs.first;
      documentId = mainUserSnapshot.id;
      print(email);
      // Access the user data
      userName = mainUserSnapshot['userName'];
      country = mainUserSnapshot['country'];
      wins = mainUserSnapshot['wins'];
      losses = mainUserSnapshot['losses'];
      // You can update other MainUser fields similarly
    } else {
      print('User not found');
    }
  }

 static Future<UserData?> getUserById(String docId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(docId).get();

      if (userDoc.exists) {
        UserData userData = UserData(
          documentId: userDoc.id,
          userId: null, // Assuming document ID is also user ID
          userName: userDoc['userName'],
          country: userDoc['country'],
          email: userDoc['email'],
          losses: userDoc['losses'],
          wins: userDoc['wins'],
        );
        print("Get user: ${userData.documentId}");
        print("Get user: ${userData.userName}");
        print("Get user: ${userData.email}");
        return userData;
      } else {
        print('User with ID $docId not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  Future<void> updateDb() async{
    if (userName == null || email == null) {
      print('Error: Some required data is null');
      return;
    }

    // print("doc: ${documentId}");
    // print("id: ${userId}");
    // print("username: $userName");
    // print("email: $email");
    FirebaseFirestore.instance
        .collection('users') // Specify the collection
        .doc(documentId) // Specify the document ID
        .set({
          'country':country,
          'email': email,
          'losses': losses,
          'userName': userName,
          'wins': wins,
        })
        .then((value) => print('user successfully saved'))
        .catchError((error) => print('Failed to save user: $error'));
  }
  
  void clearUser() {
    documentId = null;
    userId = null;
    country = null;
    email = null;
    losses = 0;
    userName = null;
    wins = 0;
  }

}