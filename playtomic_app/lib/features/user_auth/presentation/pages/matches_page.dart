import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/features/app/user_profile/MainUser.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/wedstrijden_list.dart';

class WedstrijdenPage extends StatefulWidget {
  const WedstrijdenPage({Key? key}) : super(key: key);

  @override
  _WedstrijdenState createState() => _WedstrijdenState();

  Future<void> deleteReservation(String reservationId) async {
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(reservationId)
        .delete();
  }

  Future<void> createMatchAndDeleteReservation(
      BuildContext context, ReservedField selectedField, bool isPublic) async {
    // Verkrijg de tijd en locatie van het geselecteerde veld voor het maken van de wedstrijd
    String time = selectedField.reservationTime;
    String location = selectedField.fieldName;

    String? playerName; // Declare the playerName variable here

    // Show dialog to enter player name
    playerName = await showDialog<String>(
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
                Navigator.pop(
                    context, playerName); // Passing the playerName when saving
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (playerName != null) {
      // Maak de wedstrijd in de Firestore-collectie 'matches'
      DocumentReference matchRef =
          await FirebaseFirestore.instance.collection('matches').add({
        'time': time,
        'location': location,
        'team1': [playerName], // Include the playerName here
        'team2': [],
        'available_slots': 3,
        'isPublic': isPublic,
      });

      // Verwijder de geselecteerde reservering uit de Firestore-collectie 'reservations'
      await deleteReservation(selectedField.reservationId);

      // Navigeer naar de juiste pagina
      Navigator.pop(context); // Sluit dialoogvenster
      Navigator.pushNamed(
          context, isPublic ? '/open_matches' : '/user_matches');
    }
  }
}

class _WedstrijdenState extends State<WedstrijdenPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const OpenWedstrijdenPage(),
    const UserWedstrijdenPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Open Wedstrijden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mijn Wedstrijden',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchReservedFieldsAndShowDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _fetchReservedFieldsAndShowDialog(BuildContext context) async {
    List<ReservedField> reservedFields = await getReservedFields();

    if (reservedFields.isEmpty) {
      // Als er geen gereserveerde velden zijn, toon een melding
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Geen velden gereserveerd'),
            content: const Text('Je hebt nog geen velden gereserveerd.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Toon dialoogvenster om veld te selecteren
    ReservedField? selectedField = await showDialog<ReservedField>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecteer een veld'),
          content: SingleChildScrollView(
            child: ListBody(
              children: reservedFields.map((reservedField) {
                return ListTile(
                  title: Text(
                    '${reservedField.fieldName} [${reservedField.reservationTime}]',
                  ),
                  onTap: () {
                    Navigator.of(context).pop(reservedField);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // Als geen veld is geselecteerd, stop dan met de methode
    if (selectedField == null) return;

    // Toon dialoogvenster om type wedstrijd te selecteren
    bool? isPublic = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Wedstrijdtype',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true); // Openbare wedstrijd
                  },
                  child: const Text(
                    'Openbaar',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false); // Privé wedstrijd
                  },
                  child: const Text(
                    'Privé',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Als geen type wedstrijd is geselecteerd, stop dan met de methode
    if (isPublic == null)
      return;
    else {
      // Terug naar de WedstrijdenPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WedstrijdenPage(),
        ),
      );
    }

    // Maak de wedstrijd en verwijder de reservering
    widget.createMatchAndDeleteReservation(context, selectedField, isPublic);
  }

  Future<List<ReservedField>> getReservedFields() async {
    String? currentUserId = MainUser.user.userId;

    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: currentUserId)
        .get();

    List<ReservedField> reservedFields = [];

    for (QueryDocumentSnapshot reservation in reservationSnapshot.docs) {
      String fieldId = reservation['fieldId'];
      String reservationId =
          reservation.id; // Gebruik de id van de QueryDocumentSnapshot
      DocumentSnapshot fieldSnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(fieldId)
          .get();
      String fieldName = fieldSnapshot['name'];
      String reservationTime = reservation['time'];

      reservedFields.add(ReservedField(
        fieldId: fieldId,
        fieldName: fieldName,
        reservationTime: reservationTime,
        reservationId: reservationId,
      ));
    }

    return reservedFields;
  }
}

class ReservedField {
  final String fieldId;
  final String fieldName;
  final String reservationTime;
  final String reservationId;

  ReservedField({
    required this.fieldId,
    required this.fieldName,
    required this.reservationTime,
    required this.reservationId,
  });
}
