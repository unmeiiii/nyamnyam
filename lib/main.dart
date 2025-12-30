import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screen/welcome_screen.dart';
// import 'firebase_options.dart'; // ONLY if you used flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // ← uncomment ONLY if you have firebase_options.dart
  );

  runApp(const NyamNyamApp());
}

class NyamNyamApp extends StatelessWidget {
  const NyamNyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nyam-Nyam',
      home: const WelcomeScreen(),
    );
  }
}
