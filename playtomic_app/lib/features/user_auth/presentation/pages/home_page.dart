import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/login_page.dart';
import 'package:playtomic_app/global/common/toast.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Reservation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State {
// Add necessary variables here
  late DateTime _focusedDay;
  late ValueNotifier<DateTime> _selectedDay;
  late CollectionReference _fieldsCollection;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = ValueNotifier(DateTime.now());
    _fieldsCollection = FirebaseFirestore.instance.collection('fields');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, "/login");
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(day, _selectedDay.value);
            },
            onDaySelected: (selectedDay, focusedDay) {
              _focusedDay = selectedDay;
              _selectedDay.value = selectedDay;
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Field>>(
              stream: _fieldsCollection.snapshots().map((snapshot) =>
                  snapshot.docs.map((doc) => Field.fromSnapshot(doc)).toList()),
              builder: (context, AsyncSnapshot<List<Field>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Geen velden beschikbaar');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return FieldListItem(
                        field: snapshot.data![index],
                        selectedDay: _selectedDay,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FieldListItem extends StatelessWidget {
  final Field field;
  final ValueNotifier<DateTime> selectedDay;

  const FieldListItem({
    super.key,
    required this.field,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showReservationDialog(context, field);
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.network(
              field.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Location: ${field.location}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Available Times: ${field.availableTimes.join(", ")}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDialog(BuildContext context, Field field) {
    final List<String> futureAvailableTimes =
        field.availableTimes.where((time) {
      final String startTime = time.split(' - ')[0];
      final DateTime startDateTime = DateFormat('h:mm a').parse(startTime);

      final DateTime selectedDateTime = DateTime(
        selectedDay.value.year,
        selectedDay.value.month,
        selectedDay.value.day,
        startDateTime.hour,
        startDateTime.minute,
      );

      final bool isToday = isSameDay(selectedDay.value, DateTime.now());
      final bool isFuture = selectedDateTime.isAfter(DateTime.now()) ||
          (isToday && startDateTime.hour >= DateTime.now().hour);
      return isFuture;
    }).toList();

    if (futureAvailableTimes.isEmpty) {
      // Toon een melding als er geen beschikbare tijden zijn
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Geen beschikbare tijden'),
            content: Text(
                'Er zijn geen beschikbare tijden voor ${field.name} op deze dag.'),
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
    } else {
      // Toon het reserveringsdialoogvenster als er beschikbare tijden zijn
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reserve ${field.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: futureAvailableTimes.map((time) {
                return ListTile(
                  title: Text(time),
                  onTap: () {
                    // Verwijder de tijd uit beschikbare tijden en pas het formaat aan
                    final String formattedTime =
                        time.replaceAll(RegExp(r' - .*'), '');
                    _handleReservation(context, field, formattedTime);
                    field.availableTimes.remove(
                        time); // Verwijder de tijd uit beschikbare tijden
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }

  void _handleReservation(
      BuildContext context, Field field, String time) async {
    Navigator.pop(context);

    // Formatteren van de geselecteerde tijd
    final formattedTime = DateFormat('h:mm a').format(
      DateFormat('h:mm a').parse(time),
    );

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final reservationRef =
            FirebaseFirestore.instance.collection('reservations');
        await reservationRef.add({
          'userId': currentUser.uid,
          'fieldId': field.documentId,
          'time': time,
          'selectedDate': DateFormat('yyyy-MM-dd').format(selectedDay.value),
          'createdAt': FieldValue.serverTimestamp(),
        });

        final formattedDateTime = DateFormat('h:mm a').parse(formattedTime);
        final matchingTime = field.availableTimes.firstWhere((time) {
          final timeRange = time.split(' - ');
          final startTime = DateFormat('h:mm a').parse(timeRange[0]);
          final endTime = DateFormat('h:mm a').parse(timeRange[1]);
          return formattedDateTime == startTime;
        }, orElse: () => "");

        if (matchingTime != null) {
          await FirebaseFirestore.instance
              .collection('fields')
              .doc(field.documentId)
              .update({
            'available_times': FieldValue.arrayRemove([matchingTime]),
          });
          showToast(message: 'Reserved ${field.name} at $time');
        } else {
          print('Time $formattedTime not found in availableTimes array');
        }
      }
    } catch (e) {
      print('Error adding reservation: $e');
      showToast(message: 'Failed to make reservation');
    }
  }
}

class Field {
  final String
      documentId; // Voeg een attribuut toe om het document-ID op te slaan
  final String name;
  final String location;
  final List<String> availableTimes;
  final String imageUrl;

  Field({
    required this.documentId, // Voeg documentId toe aan de constructor
    required this.name,
    required this.location,
    required this.availableTimes,
    required this.imageUrl,
  });

  factory Field.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Field(
      documentId: snapshot.id, // Sla het document-ID op
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      availableTimes: List<String>.from(data['available_times'] ?? []),
      imageUrl: data['image_url'] ?? '',
    );
  }
}
