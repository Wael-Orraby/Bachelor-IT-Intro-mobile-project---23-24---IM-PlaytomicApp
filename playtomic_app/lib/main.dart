import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Added
import 'package:intl/intl.dart';
import 'package:playtomic_app/features/app/splash_screen/splash_screen.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/user_profile.dart';
import 'package:playtomic_app/features/user_auth/presentation/pages/club_locations_page.dart';
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

  // Genereer velden voor 1 maand na vandaag
  final DateTime now = DateTime.now();
  final DateTime startDate = DateTime(now.year, now.month, now.day);

  for (int i = 1; i < 30; i++) {
    final DateTime date = startDate.add(Duration(days: i));
    final String formattedDate =
        DateFormat('dd/MM').format(date); // Formatteer de datum

    // Controleer eerst of het veld al bestaat voor deze datum
    final fieldExists = await checkFieldExists(fieldsCollection, formattedDate);
    if (!fieldExists) {
      // Voeg het veld alleen toe als het nog niet bestaat
      // Genereer beschikbare tijden voor elk uur van 10 AM tot 10 PM
      final List<String> availableTimes = List.generate(6, (index) {
        final int startHour = 10 + index * 2;
        final String startTime =
            '${startHour % 12 == 0 ? 12 : startHour % 12}:00 ${startHour < 12 ? 'AM' : 'PM'}';
        final String endTime =
            '${((startHour + 2) % 12 == 0) ? 12 : (startHour + 2) % 12}:00 ${(startHour + 2) < 12 ? 'AM' : 'PM'}';
        return '$formattedDate $startTime - $endTime';
      });

      // Voor elk veld voor elke dag van het jaar toevoegen
      for (int j = 1; j <= 5; j++) {
        final String name = 'Field $j';
        final String location = 'Location ${String.fromCharCode(65 + j)}';
        const String imageUrl =
            'https://th.bing.com/th/id/R.29259161cd9b0bac3ef8fc767bb152d0?rik=Q8Bf63bV4n9BQQ&pid=ImgRaw&r=0';

        // Voeg veldgegevens toe aan Firestore als een map
        await fieldsCollection.add({
          'name': name,
          'location': location,
          'available_times': availableTimes,
          'image_url': imageUrl,
          'available_dates': [
            formattedDate
          ], // Sla de datum op in het gewenste formaat
        });
      }
    }
  }
}

Future<bool> checkFieldExists(
    CollectionReference collection, String formattedDate) async {
  final snapshot = await collection
      .where('available_dates', arrayContains: formattedDate)
      .get();
  return snapshot.docs.isNotEmpty;
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
        '/club_locations': (context) => const ClubLocationsPage(),
        '/profile': (context) => const UserProfilePage(),
      },
    );
  }
}
