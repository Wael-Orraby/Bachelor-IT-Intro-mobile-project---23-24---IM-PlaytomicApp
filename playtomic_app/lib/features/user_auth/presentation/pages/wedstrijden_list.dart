import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/features/app/user_profile/MainUser.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/match_details_page.dart';

class OpenWedstrijdenPage extends StatelessWidget {
  const OpenWedstrijdenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Wedstrijden'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .where('isPublic', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Geen openbare wedstrijden beschikbaar'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String title = data['title'] ?? '';
              String location = data['location'] ?? '';
              String time = data['time'] ?? '';
              int availableSlots = data['available_slots'] ?? 0;
              bool isPublic = data['isPublic'] ?? false;
              bool isCompleted = data['status'] == 'completed';
              String winner = data['winner'] ?? '';

              List<String> team1 = List<String>.from(data['team1'] ?? []);
              List<String> team2 = List<String>.from(data['team2'] ?? []);

              bool isJoinable = availableSlots > 0;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MatchDetailsPage(matchId: document.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Locatie: $location'),
                        Text('Tijd: $time'),
                        Text('Beschikbare plaatsen: $availableSlots'),
                        Text(isPublic ? 'Openbaar' : 'Privé'),
                        if (isCompleted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Text('Status: Beëindigd'),
                              Text('Eindwinnaar: $winner'),
                            ],
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: isJoinable
                              ? ElevatedButton(
                                  onPressed: () {
                                    _joinMatch(
                                        document.id, team1, team2, context);
                                  },
                                  child: const Text('Join'),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MatchDetailsPage(
                                            matchId: document.id),
                                      ),
                                    );
                                  },
                                  child: const Text('Bekijk match details'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _joinMatch(String matchId, List<String> team1, List<String> team2,
      BuildContext context) async {
    String? currentUserId = MainUser.userId;

    String? playerName;
    // Toon dialoogvenster om speler naam in te voeren
    playerName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Voer je naam in'),
          content: TextField(
            onChanged: (value) {
              playerName = value;
            },
            decoration: const InputDecoration(hintText: 'Naam'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, playerName);
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (playerName != null) {
      Map<String, dynamic> updateData = {};

      if (team1.length < 2) {
        updateData['team1'] = FieldValue.arrayUnion([playerName]);
      } else {
        updateData['team2'] = FieldValue.arrayUnion([playerName]);
      }

      updateData['available_slots'] = FieldValue.increment(-1);

      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .update(updateData);

      // Fetch the updated document data
      DocumentSnapshot updatedDoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .get();

      int availableSlots = updatedDoc['available_slots'];
      if (availableSlots == 0) {
        // Call function to assign teams and declare winner with sets
        assignTeamsAndDeclareWinnerWithSets(matchId, team1, team2);
      }
    }
  }
}

enum GameResult { Team1Wins, Team2Wins }

class MatchSet {
  final String winner;
  final int team1Score;
  final int team2Score;

  MatchSet(
      {required this.winner,
      required this.team1Score,
      required this.team2Score});
}

GameResult determineGameWinner(List<MatchSet> sets) {
  int team1Wins = 0;
  int team2Wins = 0;

  for (var set in sets) {
    if (set.winner == 'Team 1') {
      team1Wins++;
    } else if (set.winner == 'Team 2') {
      team2Wins++;
    }
  }

  if (team1Wins > team2Wins) {
    return GameResult.Team1Wins;
  } else if (team2Wins > team1Wins) {
    return GameResult.Team2Wins;
  } else {
    return GameResult
        .Team1Wins; // In geval van gelijkspel, voorbeeld: Team 1 wint
  }
}

List<MatchSet> generateSets(int numberOfSets) {
  List<MatchSet> sets = [];

  for (int i = 0; i < numberOfSets; i++) {
    int team1Score = Random().nextInt(11);
    int team2Score = Random().nextInt(11);

    String winner = (team1Score > team2Score) ? 'Team 1' : 'Team 2';

    sets.add(MatchSet(
        winner: winner, team1Score: team1Score, team2Score: team2Score));
  }

  return sets;
}

void assignTeamsAndDeclareWinnerWithSets(
    String matchId, List<String> team1, List<String> team2) async {
  // Retrieve teams from Firestore to ensure we have the latest data
  DocumentSnapshot matchSnapshot =
      await FirebaseFirestore.instance.collection('matches').doc(matchId).get();
  List<String> team1FromFirebase =
      List<String>.from(matchSnapshot.get('team1') ?? []);
  List<String> team2FromFirebase =
      List<String>.from(matchSnapshot.get('team2') ?? []);

  // Check if both teams have at least 2 players
  if (team1FromFirebase.length < 2 || team2FromFirebase.length < 2) {
    print('Error: Not enough players to assign teams');
    return;
  }

  List<String> allPlayers = [...team1FromFirebase, ...team2FromFirebase];
  allPlayers.shuffle(); // Shuffle the players list

  // Assigning players to random teams
  List<String> team1Players = allPlayers.sublist(0, 2);
  List<String> team2Players = allPlayers.sublist(2, 4);

  // Generating sets
  List<MatchSet> sets = generateSets(6); // Example: Generating 6 sets

  // Determining the winner based on sets
  GameResult winner = determineGameWinner(sets);

  // Update data in Firestore
  await FirebaseFirestore.instance.collection('matches').doc(matchId).update({
    'team1': team1Players,
    'team2': team2Players,
    'sets': sets
        .map((set) => {
              'winner': set.winner,
              'team1Score': set.team1Score,
              'team2Score': set.team2Score
            })
        .toList(),
    'winner': winner == GameResult.Team1Wins ? 'Team 1' : 'Team 2',
    'status': 'completed',
  });
}

class UserWedstrijdenPage extends StatelessWidget {
  const UserWedstrijdenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Wedstrijden'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .where('isPublic', isEqualTo: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Geen privé wedstrijden beschikbaar'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String title = data['title'] ?? '';
              String location = data['location'] ?? '';
              String time = data['time'] ?? '';
              int availableSlots = data['available_slots'] ?? 0;
              bool isPublic = data['isPublic'] ?? false;

              return ListTile(
                title: Text(title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Locatie: $location'),
                    Text('Tijd: $time'),
                    Text('Beschikbare plaatsen: $availableSlots'),
                    Text(isPublic ? 'Openbaar' : 'Privé'),
                  ],
                ),
                onTap: () {
                  // Navigatielogica om naar de details van de wedstrijd te gaan
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
