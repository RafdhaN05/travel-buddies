import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  // Makes sure Flutter is fully initialized before Firebase starts
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Firebase using the configuration for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Starts the Travel Buddies application
  runApp(const TravelBuddiesApp());
}

class TravelBuddiesApp extends StatelessWidget {
  const TravelBuddiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,// Removes the DEBUG banner shown during development
      title: 'Travel Buddies',  // Application title
      
      theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      useMaterial3: true,
      ),// Defines the overall app theme

      // Opens the Login screen when the app starts
      home: const LoginScreen(),
    );
  }
}