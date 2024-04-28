import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Added
import 'package:playtomic_app/features/app/splash_screen/splash_screen.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/home_page.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/login_page.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:playtomic_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await writeDataToFirestore(); // Write data to Firestore
  runApp(const MainApp());
}

Future<void> writeDataToFirestore() async {
  final CollectionReference fieldsCollection =
      FirebaseFirestore.instance.collection('fields');

  // Sample field data
  List<Map<String, dynamic>> fieldData = [];

  // Generate random field data
  for (int i = 1; i <= 5; i++) {
    final String name = 'Field $i';
    final String location = 'Location ${String.fromCharCode(65 + i)}';
    final List<String> availableTimes =
        generateAvailableTimes(); // Generate available times
    const String imageUrl =
        'https://th.bing.com/th/id/R.29259161cd9b0bac3ef8fc767bb152d0?rik=Q8Bf63bV4n9BQQ&pid=ImgRaw&r=0';

    final fieldExists = await checkFieldExists(fieldsCollection, name);
    if (!fieldExists) {
      // Voeg veldgegevens toe aan fieldData als een map
      fieldData.add({
        'name': name,
        'location': location,
        'available_times': availableTimes,
        'image_url': imageUrl,
      });
    }
  }

  // Schrijf elk velddocument naar Firestore
  fieldData.forEach((field) async {
    await fieldsCollection
        .add(field); // Voeg het velddocument toe aan Firestore
  });
}

Future<bool> checkFieldExists(
    CollectionReference collection, String name) async {
  final snapshot = await collection.where('name', isEqualTo: name).get();
  return snapshot.docs.isNotEmpty;
}

List<String> generateAvailableTimes() {
  final List<String> times = [];
  final DateTime now = DateTime.now();
  final int currentHour = now.hour;

  // Bepaal of het momenteel AM of PM is
  final String period = currentHour < 12 ? 'AM' : 'PM';

  // Bepaal het startuur op basis van het huidige uur
  int startHour;
  if (currentHour < 10) {
    startHour =
        10; // Als het huidige uur vóór 10 uur 's ochtends is, start dan om 10 uur 's ochtends
  } else if (currentHour < 14) {
    startHour = currentHour + 2; // Start twee uur na het huidige uur
  } else {
    startHour = 10; // Start om 10 uur 's ochtends op de volgende dag
  }

  // Genereer beschikbare tijden vanaf het startuur tot 10 uur 's avonds
  for (int i = startHour; i < 22; i += 2) {
    final String startTime =
        '${i % 12 == 0 ? 12 : i % 12}:00 ${i < 12 ? 'AM' : 'PM'}';
    final String endTime =
        '${((i + 2) % 12 == 0) ? 12 : (i + 2) % 12}:00 ${(i + 2) < 12 ? 'AM' : 'PM'}';
    times.add('$startTime - $endTime');
  }

  return times;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Playtomic',
      routes: {
        '/': (context) => const SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
