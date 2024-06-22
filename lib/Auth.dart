import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonipat/data/dataList.dart';
import 'package:sonipat/loginPage.dart';
import 'package:sonipat/signUpPage.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool loggedIn = false;
  String userId = '';

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('userId');
    if (user != null) {
      setState(() {
        loggedIn = true;
        userId = user;
      });
    }
  }

  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loggedIn
          ? null
          : AppBar(
              title: Text("Sonipat Rotak FMS"),
              centerTitle: true,
            ),
      body: loggedIn
          ? DataList(userId: userId)
          : ListView(
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
