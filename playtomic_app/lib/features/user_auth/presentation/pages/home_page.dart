import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:playtomic_app/features/app/user_profile/UserData.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/club_locations_page.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/login_page.dart';
import 'package:playtomic_app/global/common/toast.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/club_locations': (context) => ClubLocationsPage(),
      },
      // Plaats BottomNavigationBar buiten Scaffold
      home: Scaffold(
        body: const HomePage(),
        bottomNavigationBar: const MyBottomNavigationBar(),
      ),
    );
  }
}

// BottomNavigationBar aparte widget maken
class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Clublocaties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
      currentIndex: _currentIndex(context),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        _onItemTapped(context, index);
      },
    );
  }

  int _currentIndex(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name == '/home') {
      return 0;
    } else if (ModalRoute.of(context)?.settings.name == '/club_locations') {
      return 1;
    }
    else if (ModalRoute.of(context)?.settings.name == '/profile') {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/club_locations');
    }
    else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              UserData.logOut();
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
                  // Filter de velden op basis van de geselecteerde datum
                  final filteredFields = snapshot.data!.where((field) =>
                      field.availableDates.contains(
                          DateFormat('dd/MM').format(_selectedDay.value)));

                  if (filteredFields.isEmpty) {
                    return const Text('Geen velden beschikbaar op deze datum');
                  }

                  return ListView.builder(
                    itemCount: filteredFields.length,
                    itemBuilder: (context, index) {
                      return FieldListItem(
                        field: filteredFields.elementAt(index),
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
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}

class FieldListItem extends StatelessWidget {
  final Field field;
  final ValueNotifier<DateTime> selectedDay;

  const FieldListItem({
    Key? key,
    required this.field,
    required this.selectedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showAvailableTimesDialog(context, field);
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

  void _showAvailableTimesDialog(BuildContext context, Field field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Beschikbare tijden voor ${field.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: field.availableTimes.map((time) {
              return ListTile(
                title: Text(time),
                onTap: () {
                  _handleReservation(context, field, time);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handleReservation(
      BuildContext context, Field field, String time) async {
    Navigator.pop(context);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final reservationRef =
            FirebaseFirestore.instance.collection('reservations');
        await reservationRef.add({
          'userId': currentUser.uid,
          'fieldId': field.documentId,
          'time': time,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Zoek de index van de tijd in availableTimes
        final int index = field.availableTimes.indexOf(time);
        if (index != -1) {
          // Verwijder de tijd op basis van de index
          field.availableTimes.removeAt(index);

          // Werk het veld bij in Firestore met de bijgewerkte lijst van beschikbare tijden
          await FirebaseFirestore.instance
              .collection('fields')
              .doc(field.documentId)
              .update({
            'available_times': field.availableTimes,
          });
        }

        showToast(message: 'Reserved ${field.name} at $time');
      } else {
        showToast(message: 'User not logged in');
      }
    } catch (e) {
      print('Error adding reservation: $e');
      showToast(message: 'Failed to make reservation');
    }
  }
}

class Field {
  final String documentId;
  final String name;
  final String location;
  final String imageUrl;
  final List<String> availableTimes;
  final List<String> availableDates; // Voeg beschikbare datums toe

  Field({
    required this.documentId,
    required this.name,
    required this.location,
    required this.availableTimes,
    required this.availableDates,
    required this.imageUrl,
  });

  factory Field.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Field(
      documentId: snapshot.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['image_url'] ?? '',
      availableTimes: List<String>.from(data['available_times'] ?? []),
      availableDates: List<String>.from(data['available_dates'] ??
          []), // Haal beschikbare datums op uit Firestore
    );
  }
}
