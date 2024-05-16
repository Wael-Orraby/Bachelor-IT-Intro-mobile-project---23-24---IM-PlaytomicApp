import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playtomic_app/features/app/user_profile/UserData.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  MatchDetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class Sets {
  final int team1;
  final int team2;
  final String winner;

  Sets({required this.team1, required this.team2, required this.winner});

  factory Sets.fromMap(Map<String, dynamic> map) {
    return Sets(
      team1: map['team1Score'] ?? 0,
      team2: map['team2Score'] ?? 0,
      winner: map['winner'] ?? "",
    );
  }
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  List<String?> team1PlayersData = [];
  List<String?> team2PlayersData = [];
  List<String?> team1Scores = [];
  List<Sets?>? totaalSets = [];
  String winner = "";
  String status = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('matches')
        .doc(widget.matchId)
        .get();
    if (!snapshot.exists) return;

    Map<String, dynamic> matchData = snapshot.data() as Map<String, dynamic>;
    List<String> team1Players = List<String>.from(matchData['team1'] ?? []);
    List<String> team2Players = List<String>.from(matchData['team2'] ?? []);

    List<Map<String, dynamic>> setsData =
        List<Map<String, dynamic>>.from(matchData['sets'] ?? []);
    totaalSets = setsData.map((setData) => Sets.fromMap(setData)).toList();

    winner = matchData['winner'] ?? '';
    status = matchData['status'] ?? 'completed';

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
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TEAMS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                      textBaseline: TextBaseline.alphabetic,
                    )),
                const SizedBox(height: 10),
                const Text(
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
                const SizedBox(height: 10),
                const Text(
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
                            style: const TextStyle(fontSize: 16),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SETS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    if (totaalSets != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0), // Adjust the padding as needed
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align children to the start (left)
                          children: totaalSets!.asMap().entries.map((entry) {
                            int i = entry.key;
                            Sets? set = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align children to the start (left)
                              children: [
                                Text(
                                  "Set ${i + 1}",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left:
                                            8.0), // Adjust the padding as needed
                                    child: Column(children: [
                                      Text(
                                        'Team 1: ${set?.team1}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Team 2: ${set?.team2}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ]))
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    if (status == "completed")
                      Column(children: [
                        Text(
                          'Winner Is: $winner!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        )
                      ])
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
