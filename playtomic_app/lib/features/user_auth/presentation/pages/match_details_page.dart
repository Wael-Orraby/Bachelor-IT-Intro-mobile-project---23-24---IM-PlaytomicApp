import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playtomic_app/features/app/user_profile/UserData.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  MatchDetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  List<String?> team1PlayersData = [];
  List<String?> team2PlayersData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).get();
    if (!snapshot.exists) return;

    Map<String, dynamic> matchData = snapshot.data() as Map<String, dynamic>;
    List<String> team1Players = List<String>.from(matchData['team1'] ?? []);
    List<String> team2Players = List<String>.from(matchData['team2'] ?? []);

    for (String value in team1Players) {
      UserData? userData = await UserData.getUserById(value);
        if (userData != null) {
          team1PlayersData.add(userData.userName);
        } else {
          team1PlayersData.add(value);
        }
    }

    for (String value in team2Players) {
      UserData? userData = await UserData.getUserById(value);
     
        if (userData != null) {
          team2PlayersData.add(userData.userName);
        } else {
          team2PlayersData.add(value);
        }
    }
     setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team 1 Spelers:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: team1PlayersData
                  .map((player) => Text(
                        player ?? '',
                        style: TextStyle(fontSize: 16),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Team 2 Spelers:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: team2PlayersData
                  .map((player) => Text(
                        player ?? '',
                        style: TextStyle(fontSize: 16),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
