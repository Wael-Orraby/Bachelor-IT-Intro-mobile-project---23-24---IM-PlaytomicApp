
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

class UserData{
  String? documentId;
  String? userId; // 'n3DEgoZvQVP2dSvtohA9pKjHqNo2';
  String? email; // "wael1@gmail.com";
  String? userName;
  String? country;
  Field? playing;
  int? win;
  int? los;
  String? teamName;

  UserData({this.documentId, this.userId, this.email, this.userName, this.country, this.win, this.los, this.teamName});

  void updateDb(){

    if (userName == null || email == null || playing == null) {
      print('Error: Some required data is null');
      return;
    }

    print("username: $userName");
    print("email: $email");
    print("playing: ${playing!.name}");

    String? docId =
        documentId ?? FirebaseFirestore.instance.collection('users').doc().id;

    FirebaseFirestore.instance
        .collection('users') // Specify the collection
        .doc(docId) // Specify the document ID
        .set({
          'country':country,
          'email': email,
          'loss': los,
          'playing': playing!.documentId,
          'teamName': teamName,
          'userName': userName,
          'win': win,
        })
        .then((value) => print('user successfully saved'))
        .catchError((error) => print('Failed to save user: $error'));
  }
  
  void clearUser() {
    documentId = null;
    userId = null;
    country = null;
    email = null;
    los = null;
    playing = null;
    teamName = null;
    userName = null;
    win = null;
  }

}