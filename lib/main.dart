import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sonipat/Auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDkkFAyCSMHnGJOWCuW8hdl_WbX0UoS1XE",
          authDomain: "flutter-notification-3dcb3.firebaseapp.com",
          projectId: "flutter-notification-3dcb3",
          storageBucket: "flutter-notification-3dcb3.appspot.com",
          messagingSenderId: "1146117969",
          appId: "1:1146117969:web:ee583d500376ba81673d70",
          measurementId: "G-TWCE7GYXDC"
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonipat BPCL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
