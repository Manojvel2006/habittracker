// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC5SsdHQcXNFpCNic7FrckiH2617NvYykw",
        authDomain: "habit-tracker-app-1b42e.firebaseapp.com",
        projectId: "habit-tracker-app-1b42e",
        storageBucket: "habit-tracker-app-1b42e.appspot.com",
        messagingSenderId: "966591421828",
        appId: "1:966591421828:web:103bd39056525e77f711d1",
        measurementId: "G-F4RCG0Z4LL",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
