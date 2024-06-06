import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playtomic_app/components/button/cbutton.dart';
import 'package:playtomic_app/features/app/user_profile/MainUser.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/wedstrijden_list.dart';

class WedstrijdenPage extends StatefulWidget {
  const WedstrijdenPage({super.key});

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

    String? playerId; // Declare the playerId variable here
    // Show dialog to enter player name
    playerId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reservation details'),
          content: SizedBox(
            width: double.minPositive,
            height: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text("Veld: ${selectedField.fieldName}"),
                Text("Tijd: ${selectedField.reservationTime}"),
                Text("Toegang: ${isPublic ? 'Public' : 'Private'}"),
              ],
            ),
          ),
          actions: [
            CButton(
              style: ButtonType.RED,
              text: 'Annuleren',
              onPressed: () => Navigator.pop(context),
            ),
            CButton(
              style: ButtonType.PRIMARY,
              text: 'Opslaan',
              onPressed: () => Navigator.pop(context, MainUser.user.documentId),
            ),
          ],
        );
      },
    );

    if (playerId != null) {
      // Maak de wedstrijd in de Firestore-collectie 'matches'
      DocumentReference matchRef =
          await FirebaseFirestore.instance.collection('matches').add({
        'time': time,
        'location': location,
        'team1': [playerId], // Include the playerId here
        'team2': [],
        'available_slots': 3,
        'isPublic': isPublic,
        'owner': MainUser.user.documentId,
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
                CButton(
                  style: ButtonType.LIGHTBLUE,
                  text: "Openbaar",
                  onPressed: () {
                    Navigator.of(context).pop(true); // Openbare wedstrijd
                  },
                ),
                const SizedBox(height: 20),
                CButton(
                  style: ButtonType.LIGHTBLUE,
                  text: "Privé",
                  onPressed: () {
                    Navigator.of(context).pop(false); // Privé wedstrijd
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  print("end of wiget..");
    // Als geen type wedstrijd is geselecteerd, stop dan met de methode
    if (isPublic == null){
      print(isPublic);
      return;
    }
    else {
      // Terug naar de WedstrijdenPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WedstrijdenPage(),
        ),
      );
    }
  print("new wiget normaly");
    // Maak de wedstrijd en verwijder de reservering
   await widget.createMatchAndDeleteReservation(context, selectedField, isPublic);
  }

  Future<List<ReservedField>> getReservedFields() async {
    String? currentUserId = MainUser.user.userId;

    List<ReservedField> reservedFields = [];

    MainUser.user.userFieldsList ?? MainUser.getUserFields();

    for (int i = 0; i < MainUser.user.userFieldsList!.length; i++) {
      Field field = MainUser.user.userFieldsList![i];
      String timer = MainUser.user.userFieldTimerList![i];
      String reservationId = MainUser.user.userReservationIdList![i];
      reservedFields.add(ReservedField(
        fieldId: field.documentId,
        fieldName: field.name,
        reservationTime: timer,
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
