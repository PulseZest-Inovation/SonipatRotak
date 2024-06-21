import 'package:flutter/material.dart';
import 'package:sonipat_rotak_fms/widgets/widgets.dart';

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isSignUpPressed = false;

  Future<bool> isEmailInUse(String email) async {
    QuerySnapshot emailQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return emailQuery.docs.isNotEmpty;
  }

  void _signup(BuildContext context) async {
    setState(() {
      isSignUpPressed = true;
    });
    final String email = _emailController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Toast.showToast("All the fields are required!");
    } else if (password != confirmPassword) {
      Toast.showToast("Both the passwords do not match");
    } else {
      try {
        // Validate email format
        if (!isValidEmail(email)) {
          Toast.showToast('Invalid email format');
          setState(() {
            isSignUpPressed = false;
          });
          return;
        }

        if (await isEmailInUse(email)) {
          ToastUtil.showToast('Email is already in use');
          setState(() {
            isSignUpPressed = false;
          });
          return;
        }

        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Access the user object from userCredential
        User? user = userCredential.user;
        Timestamp curr = Timestamp.now();
        DateTime targetDate = DateTime(2024, 12, 31);
        Timestamp timestamp = Timestamp.fromDate(targetDate);

        if (user != null) {
          // Add user data to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': name,
            'phone': phone,
            'email': email,
            'username': username,
            'createdAt': curr,
            'loggedIn': 0,
            'trialStart': curr,
            // 'trialEnd': curr.toDate().add(const Duration(days: 30)),
            'trialEnd': timestamp,
          });

          // Account creation successful, navigate to email verification page
          ToastUtil.showToast('Account Creation Successful!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyEmailPage(userId: user.uid),
            ),
          );
        } else {
          ToastUtil.showToast('Failed to create user');
        }
        setState(() {
          isSignUpPressed = false;
        });
      } catch (e) {
        // Handle errors
        ToastUtil.showToast('Something went wrong : $e!');
        print("Error: $e");
        setState(() {
          isSignUpPressed = false;
        });
      }
    }
    setState(() {
      isSignUpPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
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
            ),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Perform signup action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Signing up...')),
                );
              }
            },
            child: Text('Signup'),
          ),
        ],
      ),
    );
  }
}
