import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:handyman_finder/authentication/signin_screen.dart';
import 'package:handyman_finder/ui/splash_screen.dart';
import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstNameTextEditingController =
      TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController businessNameTextEditingController =
      TextEditingController();
  TextEditingController IdNoTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController addressTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  String selectedUserRole = "Handyman";
  String selectedSkill = "Electrician";

  validateForm() {
    if (firstNameTextEditingController.text.length < 3 ||
        lastNameTextEditingController.text.length < 3) {
      Fluttertoast.showToast(msg: "Names must be at least 3 characters");
    } else if (selectedUserRole == 'Handyman' &&
        businessNameTextEditingController.text.length < 3) {
      Fluttertoast.showToast(msg: "Names must be at least 3 characters");
    } else if (selectedUserRole == 'Handyman' &&
        IdNoTextEditingController.text.length != 11) {
      Fluttertoast.showToast(msg: "ID no must be 11 characters");
    } else if (selectedUserRole == 'Handyman' && selectedSkill == "") {
      Fluttertoast.showToast(msg: "Select a skill");
    } else if (selectedUserRole == 'Handyman' &&
        addressTextEditingController.text.length < 3) {
      Fluttertoast.showToast(
          msg: "Physical address field must be at least 3 characters");
    } else if (selectedUserRole == "") {
      Fluttertoast.showToast(msg: "Select a role");
    } else if (!emailTextEditingController.text.contains('@')) {
      Fluttertoast.showToast(msg: "Email address invalid");
    } else if (phoneTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number required");
    } else if (passwordTextEditingController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters");
    } else {
      saveUserInfoNow();
    }
  }

  saveUserInfoNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Processing, please wait...");
        });

    final User? firebaseUser = (await firebaseAuthObject
            .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
            .catchError(
      (msg) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Error: " + msg.toString());
      },
    ))
        .user;

    if (firebaseUser != null) {
      Map userMap = {
        "id": firebaseUser.uid,
        "firstName": firstNameTextEditingController.text.trim(),
        "lastName": lastNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
        "role": selectedUserRole.trim(),
        "accountStatus": "Verified",
        "displayPhotoUrl": "",
      };

      if (selectedUserRole == 'Handyman') {
        userMap['businessName'] = businessNameTextEditingController.text.trim();
        userMap['IDNo'] = IdNoTextEditingController.text.trim();
        userMap['address'] = addressTextEditingController.text.trim();
        userMap['skill'] = selectedSkill.trim();
        userMap['status'] = "Available";
      }

      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child('users');
      usersRef.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account has been created");

      firebaseAuthObject.signOut();

      Navigator.push(
          context, MaterialPageRoute(builder: (c) => MySplashScreen()));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Create your account for a better experience",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'User Role',
                  border: UnderlineInputBorder(),
                ),
                child: DropdownButtonFormField(
                  // dropdownColor: Colors.white54,
                  iconSize: 25,
                  // icon: Icon(Icons.car_rental),
                  hint: Text('User Role'),
                  value: selectedUserRole,
                  onChanged: (newValue) {
                    setState(() {
                      selectedUserRole = newValue.toString();
                    });
                  },
                  items: [
                    'Customer',
                    'Handyman',
                  ].map((role) {
                    return DropdownMenuItem(
                      child: Text(role, style: TextStyle(color: Colors.black)),
                      value: role,
                    );
                  }).toList(),
                ),
              ),
              TextField(
                controller: firstNameTextEditingController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                    labelText: "First Name",
                    hintText: "First Name",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.person)),
              ),
              TextField(
                controller: lastNameTextEditingController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                    labelText: "Last Name",
                    hintText: "Last Name",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.person)),
              ),
              if (selectedUserRole == "Handyman")
                TextField(
                  controller: businessNameTextEditingController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                      labelText: "Business Name",
                      hintText: "Business Name",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(Icons.business)),
                ),
              if (selectedUserRole == "Handyman")
                TextField(
                  controller: IdNoTextEditingController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                      labelText: "ID Number",
                      hintText: "ID Number",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(Icons.perm_identity)),
                ),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.email)),
              ),
              TextField(
                controller: phoneTextEditingController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                    labelText: "Contact Number",
                    hintText: "Contact Number",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.phone)),
              ),
              if (selectedUserRole == "Handyman")
                TextField(
                  controller: addressTextEditingController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                      labelText: "Physical Address",
                      hintText: "Physical Address",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(Icons.location_on)),
                ),
              if (selectedUserRole == "Handyman")
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Specialization / Skill',
                    border: UnderlineInputBorder(),
                  ),
                  child: DropdownButtonFormField(
                    iconSize: 25,
                    hint: Text('Select Skill'),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSkill = newValue.toString();
                      });
                    },
                    value: selectedSkill,
                    items: [
                      'Electrician',
                      'Gardener',
                      'Cleaner',
                      'Plumber',
                      'Carpenter'
                    ].map((skill) {
                      return DropdownMenuItem(
                        child:
                            Text(skill, style: TextStyle(color: Colors.black)),
                        value: skill,
                      );
                    }).toList(),
                  ),
                ),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Password",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.password)),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  validateForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SigninScreen()));
                },
                child: const Text(
                  "Already have an account? Login here",
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
