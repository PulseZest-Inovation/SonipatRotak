import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonipat/data/dataList.dart';
import 'package:sonipat/widgets/widgets.dart';

import 'homePage.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoginPressed = false;
  bool _obscurePassword = true;

  Future _login(BuildContext cont) async {
    setState(() {
      isLoginPressed = true;
    });
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Toast.showToast("Both the fields are required!");
    } else {
      try {
        UserCredential userCredential;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', userDoc.id);
          prefs.setString('email', userDoc['email']);
          prefs.setString('username', userDoc['username']);
          Toast.showToast('Login successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(userId: userDoc.id)),
          );
          print("Login successful");
        } else {
          print('Check the entered username and password!');
          Toast.showToast(
              'Incorrect credentials - Check the entered username and password!');
          setState(() {
            isLoginPressed = false;
          });
          return;
        }
      } catch (e) {
        // Handle any errors
        print('Error logging in: $e');
        Toast.showToast('Incorrect password! Check again.');
        setState(() {
          isLoginPressed = false;
        });
      }
    }
    setState(() {
      isLoginPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email)),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword, // toggle password visibility
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Perform login action
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Logging in...')),
                // );
                _login(context);
              }
            },
            child: isLoginPressed ? CircularProgressIndicator() : Text('Login'),
          ),
        ],
      ),
    );
  }
}
