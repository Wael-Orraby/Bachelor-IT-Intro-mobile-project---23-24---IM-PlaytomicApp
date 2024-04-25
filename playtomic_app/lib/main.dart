import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  runApp(const MainApp());
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
