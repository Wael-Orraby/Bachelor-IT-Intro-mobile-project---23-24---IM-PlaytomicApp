
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class UserData{
  String? documentId;
  String? userId; // 'n3DEgoZvQVP2dSvtohA9pKjHqNo2';
  String? email; // "wael1@gmail.com";
  String? userName;
  String? country;
  int wins = 0;
  int losses = 0;
  List<Field>? userFieldsList;
  List<String>? userFieldTimerList;

  UserData({this.documentId, this.userId, this.email, this.userName, this.country});


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

    // Iterate through userReservations
    for (QueryDocumentSnapshot reservation in userReservationsSnapshot.docs) {
      String fieldId = reservation['fieldId'];
      // Get the corresponding field
      DocumentSnapshot fieldSnapshot =
          await fieldsCollection.doc(fieldId).get();
      if (fieldSnapshot.exists) {
         timers.add(reservation['time'].toString());
        fields.add(Field.fromSnapshot(fieldSnapshot));
      }
    }

    userFieldsList = fields;
    userFieldTimerList = timers;
    
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

      // You can update other MainUser fields similarly
    } else {
      print('User not found');
    }
  }

  void updateDb(){
    if (userName == null || email == null) {
      print('Error: Some required data is null');
      return;
    }

    print("doc: ${documentId}");
    print("id: ${userId}");
    print("username: $userName");
    print("email: $email");
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