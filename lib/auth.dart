import 'package:flutter/material.dart';
import 'package:sonipat_rotak_fms/loginPage.dart';
import 'package:sonipat_rotak_fms/signUpPage.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sonipat Rotak FMS"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Image.asset(
            'assets/image/BPCL.png', // Change this to your image path
            height: 200, // Adjust the height as needed
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20),
          isLogin ? LoginForm() : SignupForm(),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              setState(() {
                isLogin = !isLogin;
              });
            },
            child: Text(isLogin
                ? "Don't have an account? Signup"
                : "Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
