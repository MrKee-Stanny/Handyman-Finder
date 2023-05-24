import 'dart:async';

import 'package:flutter/material.dart';
import 'package:handyman_finder/authentication/signin_screen.dart';

import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/utils/helpers.dart';
import 'package:handyman_finder/screens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  String welcomeText = "";
  String titleText = "";
  double boxHeight = 0;

  startTimer() {
    firebaseAuthObject.currentUser != null
        ? HelperMethods.readCurrentOnlineUserInfo()
        : null;

    Timer(const Duration(seconds: 3), () {
      setState(() {
        welcomeText = 'Welcome to';
        titleText = 'Handymen Finder';
        boxHeight = 50;
      });
    });

    Timer(
      const Duration(seconds: 6),
      () async {
        if (await firebaseAuthObject.currentUser != null) {
          currentFirebaseUser = firebaseAuthObject.currentUser;

            // home page
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => MainScreen()));
          
        } else {
          // send the user to the sign in screen
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => SigninScreen()));
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                welcomeText,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: boxHeight),
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: boxHeight),
              Image.asset(
                'assets/images/logo.png',
                height: 170,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
