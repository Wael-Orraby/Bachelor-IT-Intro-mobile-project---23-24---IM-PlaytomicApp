import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/components/button/cbutton.dart';
import 'package:playtomic_app/features/app/user_profile/MainUser.dart';
import 'package:playtomic_app/features/app/user_profile/UserData.dart';
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

          return FutureBuilder<List<Widget>>(
            future: _buildMatchWidgets(snapshot.data!.docs, context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(children: snapshot.data!);
            },
          );
        },
      ),
    );
  }

  Future<List<Widget>> _buildMatchWidgets(
    List<DocumentSnapshot> documents, BuildContext context) async {
    await MainUser.getMainUser();
    List<Widget> widgets = [];
    for (DocumentSnapshot document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String location = data['location'] ?? '';
      String time = data['time'] ?? '';
      int availableSlots = data['available_slots'] ?? 0;
      bool isPublic = data['isPublic'] ?? false;
      bool isCompleted = data['status'] == 'completed';
      String winner = data['winner'] ?? '';
      UserData? owner = await UserData.getUserById(data['owner']);
      List<String> team1 = List<String>.from(data['team1'] ?? []);
      List<String> team2 = List<String>.from(data['team2'] ?? []);
      bool isJoinable = availableSlots > 0;
      bool imOwner = false;
      String imOwnerTeam = '';
      bool imInTeam = false;
      for (String id in team1) {
        if (id == MainUser.user.documentId) {
          imInTeam = true;
          imOwnerTeam = 'team1';
          break;
        }
      }
      for (String id in team2) {
        if (id == MainUser.user.documentId) {
          imInTeam = true;
          imOwnerTeam = 'team2';
          break;
        }
      }
      if (owner!.documentId == MainUser.user.documentId) imOwner = true;
      if (owner.documentId == MainUser.user.documentId) imOwner = true;

      widgets.add(
        Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailsPage(matchId: document.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From user: ${owner.userName!}",
                    style: const TextStyle(
                      fontSize: 16,
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
                    child: Column(
                      children: [
                        if (isJoinable &&
                            ((!imInTeam && !imOwner) || (imOwner)))
                          SizedBox(
                            width: double.infinity,
                            child: CButton(
                              style: ButtonType.SECONDARY_BLUE,
                              onPressed: () {
                                _joinMatch(document.id, team1, team2, context,
                                    imOwner);
                              },
                              text: imOwner ? 'voeg random vrind toe' : 'Join',
                            ),
                          ),
                        if (!isJoinable || isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: CButton(
                              style: ButtonType.SECONDARY_BLUE,
                              text: 'Bekijk match details',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatchDetailsPage(
                                      matchId: document.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (imInTeam && isJoinable)
                          SizedBox(
                            width: double.infinity,
                            child: CButton(
                              style: ButtonType.RED,
                              text: imOwner
                                  ? "verlaten maar open houden"
                                  : "verlaten",
                              onPressed: () {
                                _leave(document.id, imOwnerTeam,
                                    MainUser.user.documentId!);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!imInTeam && imOwner && !isCompleted)
                    const SizedBox(
                      height: 10,
                    ),
                  if (!imInTeam && imOwner && !isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: CButton(
                          style: ButtonType.SECONDARY,
                          onPressed: () {
                            _joinMatch(
                                document.id, team1, team2, context, !imOwner);
                          },
                          text: 'Terug joinen'),
                    ), // Or any other empty widget
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  void _leave(String matchId, String fieldName, String valueToRemove) async {
    try {
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .update({
        'available_slots': FieldValue.increment(1),
        fieldName: FieldValue.arrayRemove([valueToRemove])
      });
      print('$fieldName Value removed successfully');
    } catch (e) {
      print('Error removing value: $e');
    }
  }
}

void _joinMatch(String matchId, List<String> team1, List<String> team2,
    BuildContext context, bool imOwner) async {
  String? playerName;
  // Toon dialoogvenster om speler naam in te voeren
  playerName = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Voeg een persoon toe'),
        content: imOwner
            ? TextField(
                onChanged: (value) {
                  playerName = value;
                },
                decoration: const InputDecoration(hintText: 'Naam'),
              )
            : const Text('Deelnemen aan wendstrijd?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: imOwner ? const Text('Nee') : const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () {
              if (imOwner) {
                Navigator.pop(context, playerName);
              } else {
                Navigator.pop(context, MainUser.user.documentId);
              }
            },
            child: imOwner ? const Text('Ja') : const Text('Opslaan'),
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
  if(winner == GameResult.Team1Wins){
    print("win1");
    for (String t1 in team1Players) {
      UserData? u = await UserData.getUserById(t1);
      if(u == null) continue;
      print("Mail: ${u.email}");
      u.wins = u.wins! + 1;
      u.updateDb();
    }
    for (String t2 in team2Players) {
      UserData? u = await UserData.getUserById(t2);
      if(u == null) continue;
      print("Mail: ${u.email}");
      u.losses = u.losses! + 1;
      u.updateDb();
    }
  }
  else if(winner == GameResult.Team2Wins){
    print("win2");
    for (String t1 in team1Players) {
      UserData? u = await UserData.getUserById(t1);
      if(u == null) continue;
      print("Mail: ${u.email}");
      u.losses = u.losses! + 1;
      await u.updateDb();
    }
    for (String t2 in team2Players) {
      UserData? u = await UserData.getUserById(t2);
      if(u == null) continue;
      print("Mail: ${u.email}");
      u.wins = u.wins! + 1;
      await u.updateDb();
    }
  }
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
