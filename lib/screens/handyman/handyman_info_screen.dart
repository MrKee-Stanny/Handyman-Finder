import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:handyman_finder/screens/handyman/profile_setup_screen.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/widgets/handyman/handyman_drawer.dart';

class HandymanInfoScreen extends StatefulWidget {
  const HandymanInfoScreen({super.key});

  @override
  State<HandymanInfoScreen> createState() => _HandymanInfoScreenState();
}

class _HandymanInfoScreenState extends State<HandymanInfoScreen> {
  GlobalKey<ScaffoldState> hSKey = GlobalKey<ScaffoldState>();

  bool openNavigationDrawer = true;
  bool _loadingImages = true;
  bool profileIncomplete = false;

  String _imageUrl = "";

  Future<void> loadImage() async {
    setState(() {
      _loadingImages = true;
    });

    final ref = FirebaseStorage.instance
        .ref()
        .child(currentFirebaseUser!.uid)
        .child('gallery');

    final result = await ref.listAll();

    if (result.items.isNotEmpty) {
      final item = result.items.first;
      final url = await item.getDownloadURL();
      _imageUrl = url;
    }

    setState(() {
      _loadingImages = false;
      if (_imageUrl == "") {
        profileIncomplete = true;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext c) => ProfileSetupScreen()));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: hSKey,
      backgroundColor: Colors.white,
      drawer: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).colorScheme.primary),
        child: HandymanDrawer(
          firstName: userModelCurrentInfo!.firstName,
          email: userModelCurrentInfo!.email,
          // role: userModelCurrentInfo!.role,
        ),
      ),
      appBar: AppBar(title: Text('Home')),
      body: SafeArea(
        child: _loadingImages
            ? ProgressDialog(
                message: "Loading...",
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _imageUrl != ""
                              ? NetworkImage(_imageUrl)
                              : NetworkImage('https://via.placeholder.com/150'),
                          fit: BoxFit.cover,
                        ),
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.grey),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          Positioned(
                            bottom: 25,
                            left: 0,
                            right: 0,
                            child: CustomPaint(
                              painter: MyPainter(),
                              child: CircleAvatar(
                                radius: 75,
                                backgroundImage: userModelCurrentInfo!
                                            .displayPhotoUrl !=
                                        ""
                                    ? NetworkImage(
                                        userModelCurrentInfo!.displayPhotoUrl!)
                                    : NetworkImage(
                                        'https://via.placeholder.com/150'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${userModelCurrentInfo!.businessName!}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Colors.green),
                          Text("Available"),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Row(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Address",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("ID Number",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Email Address",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Phone Number",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Specialization",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${userModelCurrentInfo!.firstName} ${userModelCurrentInfo!.lastName}",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            Text("${userModelCurrentInfo!.address}",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            Text("${userModelCurrentInfo!.IDNo}",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            Text("${userModelCurrentInfo!.email}",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            Text("${userModelCurrentInfo!.phone}",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            Text("${userModelCurrentInfo!.skill}",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                          ],
                        ),
                      ]),
                    ),

                    // List of booking widgets here
                  ],
                ),
              ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final left = Offset(0, size.height / 2);
    final right = Offset(size.width, size.height / 2);

    canvas.drawLine(center, left, paint);
    canvas.drawLine(center, right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
