import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MatchDetailsPage extends StatelessWidget {
  final String matchId;

  const MatchDetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('matches').doc(matchId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Wedstrijd niet gevonden',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          Map<String, dynamic> matchData =
              snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> setsData = matchData['sets'] ?? [];
          String winner = matchData['winner'] ?? '';
          List<String> team1Players =
              List<String>.from(matchData['team1'] ?? []);
          List<String> team2Players =
              List<String>.from(matchData['team2'] ?? []);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sets:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: setsData.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> setData = setsData[index];
                      int team1Score = setData['team1Score'];
                      int team2Score = setData['team2Score'];
                      String setWinner = setData['winner'];

                      return ListTile(
                        title: Text(
                          'Set ${index + 1}:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Team 1: $team1Score\nTeam 2: $team2Score\nWinnaar: $setWinner',
                          style: TextStyle(color: Colors.black87),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Eindwinnaar: $winner',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
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
                  children: team1Players
                      .map((player) => Text(
                            player,
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
                  children: team2Players
                      .map((player) => Text(
                            player,
                            style: TextStyle(fontSize: 16),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
