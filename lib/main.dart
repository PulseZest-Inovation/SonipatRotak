import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sonipat/Auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyAykAmNTA8HMLS7X4YWlOqSXjk6GrOMXw4",
    projectId: "bpcl-370b8",
    storageBucket: "bpcl-370b8.appspot.com",
    messagingSenderId: "1146117969",
    appId: "1:263383517333:android:9558a35359eed26191f39c",
  ));
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
