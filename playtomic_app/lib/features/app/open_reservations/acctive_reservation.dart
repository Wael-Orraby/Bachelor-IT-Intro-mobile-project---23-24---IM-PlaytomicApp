import 'package:playtomic_app/features/app/user_profile/UserData.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';

enum GameState {
  active,
  playing,
  ended,
}

class OwendReservation{

  Field? field;
  UserData? owner;
  List<UserData>? playersIds; //including owner in here
  GameState? gameState;

  OwendReservation({this.field, this.owner, this.playersIds, this.gameState});

  
  
}