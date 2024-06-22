import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonipat/widgets/widgets.dart';
import 'package:sonipat/Auth.dart';

void logout(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    FirebaseAuth.instance.signOut();

    Toast.showToast("Logged out!");
    print("logged out");

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AuthPage()));
  } catch (e) {
    print('Error signing out: $e');
  }
}
