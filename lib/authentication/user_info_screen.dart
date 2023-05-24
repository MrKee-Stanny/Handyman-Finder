import 'package:flutter/material.dart';
import 'package:handyman_finder/screens/admin_info_screen.dart';
import 'package:handyman_finder/screens/customer_info_screen.dart';
import 'package:handyman_finder/screens/handyman_info_screen.dart';
import 'package:handyman_finder/ui/splash_screen.dart';

import 'package:handyman_finder/utils/global.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: userModelCurrentInfo == null
          ? MySplashScreen()
              : userModelCurrentInfo!.role == 'Admin'
                  ? const AdminInfoScreen()
                  : userModelCurrentInfo!.role == 'Handyman'
                      ? HandymanInfoScreen()
                      : CustomerInfoScreen(),
    );
  }
}
