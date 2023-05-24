import 'package:flutter/material.dart';

import 'package:handyman_finder/authentication/user_info_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  double bottomPaddingMap = 0;

  @override
  Widget build(BuildContext context) {
    // print(currentFirebaseUser);

    return Scaffold(
      key: sKey,
      body: SafeArea(
        child: UserInfoScreen(),
      ),
    );
  }
}
