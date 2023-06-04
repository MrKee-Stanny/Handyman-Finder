import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:handyman_finder/authentication/signup_screen.dart';
import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/ui/splash_screen.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

class SigninScreen extends StatefulWidget {
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm() {
    if (!emailTextEditingController.text.contains('@')) {
      Fluttertoast.showToast(msg: 'Email address is not valid');
    } else if (passwordTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Password is required');
    } else {
      loginUserNow();
    }
  }

  loginUserNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Logging in, please wait...");
        });

try {
    final User? firebaseUser = (await firebaseAuthObject
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text.trim(),
                password: passwordTextEditingController.text.trim())
            )
        .user;

    if (firebaseUser != null) {
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child('users');

      usersRef.child(firebaseUser.uid).once().then((userKey) {
        final snap = userKey.snapshot;

        if (snap.value != null) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: 'Log in successful');
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext c) => MySplashScreen()));
        } else {
          Fluttertoast.showToast(msg: 'Email has no associated user account.');
          firebaseAuthObject.signOut();
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext c) => MySplashScreen()));
        }
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Log in failed");
    }} catch (e) {
      print(e);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: " + e.toString());
   
    
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/pawa.jpg'),
                    fit: BoxFit.cover,
                  ),
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    // Padding(
                    //   padding: const EdgeInsets.all(0),
                    //   // child: Image.asset(
                    //   //   'assets/images/light-logo.png',
                    //   //   height: 170,
                    //   // ),
                    // ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Email",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Password",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        validateForm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const SignUpScreen()));
                      },
                      child: const Text(
                        "Don't have an account? Register here",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (c) => const CustomerInfoScreen()));
                    //   },
                    //   child: const Text(
                    //     "View as Customer",
                    //     style: TextStyle(
                    //       color: Colors.white70,
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
