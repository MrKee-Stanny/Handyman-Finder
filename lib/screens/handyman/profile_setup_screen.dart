import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:handyman_finder/screens/handyman/handyman_info_screen.dart';

import 'package:path/path.dart' show basename;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  File? _profileImage;
  List<File> _galleryImages = [];
  DateTime now = DateTime.now();
  DateTime? _startHour;
  DateTime? _endHour;
  List<bool> _hourSlots = [];
  DateFormat timeFormatter = DateFormat('HH:mm');
  bool _isSubmitting = false;

  String getFormattedTime(time) {
    return timeFormatter.format(time);
  }

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (_currentStep == 0) {
          _profileImage = File(pickedFile.path);
        } else if (_currentStep == 1) {
          _galleryImages.add(File(pickedFile.path));
        }
      }
    });
  }

  Future<String?> uploadImageToFirebase(File file, String path) async {
    final fileName = basename(file.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child(currentFirebaseUser!.uid)
        .child(path)
        .child(fileName);

    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});

    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    print('POINT 1');

    Map<String, Object?> userMap = {
      "displayPhotoUrl": userModelCurrentInfo!.displayPhotoUrl,
    };

    print('POINT 2');

    if (_profileImage != null) {
      String? displayPhotoUrl =
          await uploadImageToFirebase(_profileImage!, 'displayPhotoUrl');
      userMap['displayPhotoUrl'] = displayPhotoUrl;
    }

    print('POINT 3');

    List<String?> galleryImageUrls = [];

    for (int i = 0; i < _galleryImages.length; i++) {
      File galleryImage = _galleryImages[i];
      String? galleryImageUrl =
          await uploadImageToFirebase(galleryImage, 'gallery');
      galleryImageUrls.add(galleryImageUrl);
    }

    print('POINT 4');

    userMap['galleryImageUrls'] = galleryImageUrls;

    List<String> bookingSlots = [];

    print('POINT 5');

    for (int i = 0; i < _hourSlots.length; i++) {
      if (_hourSlots[i] == true) {
        bookingSlots.add(
          (DateTime(now.year, now.month, now.day, _startHour!.hour + i,
                  _startHour!.minute, 0, 0))
              .toIso8601String(),
        );
      }
    }

    print('POINT 6');

    userMap['bookingSlots'] = bookingSlots;

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    usersRef.child(currentFirebaseUser!.uid).update(userMap);

    print('POINT 7');

    Fluttertoast.showToast(msg: "Profile saved!");

    setState(() {
      _isSubmitting = false;
    });
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext c) => HandymanInfoScreen()));
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _startHour = DateTime(now.year, now.month, now.day, 9, 0, 0, 0);
      _endHour = DateTime(now.year, now.month, now.day, 17, 0, 0, 0);

      final diff = _endHour!.difference(_startHour!).inHours;
      _hourSlots = [];
      for (int i = 0; i < diff; i++) {
        _hourSlots.add(false);
      }
    });
  }

  Widget _buildProfileImageStep() {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => _getImage(ImageSource.gallery),
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
            child: Icon(Icons.add_a_photo),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGalleryStep() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                children: List.generate(
                  _galleryImages.length < 5 ? _galleryImages.length + 1 : 5,
                  (index) {
                    if (index == _galleryImages.length) {
                      return GestureDetector(
                        onTap: () => _getImage(ImageSource.gallery),
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Icon(Icons.add_a_photo),
                        ),
                      );
                    } else {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Image.file(_galleryImages[index]),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: _startHour!.hour, minute: _startHour!.minute),
                );

                if (timeOfDay != null) {
                  setState(() {
                    _startHour = DateTime(now.year, now.month, now.day,
                        timeOfDay.hour, timeOfDay.minute, 0, 0);

                    final diff = _endHour!.difference(_startHour!).inHours;
                    _hourSlots = [];
                    for (int i = 0; i < diff; i++) {
                      _hourSlots.add(false);
                    }
                  });
                }
              },
              child: Text('Change Start Time'),
            ),
            ElevatedButton(
              onPressed: () async {
                final timeOfDay = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay(hour: _endHour!.hour, minute: _endHour!.minute),
                );

                if (timeOfDay != null) {
                  setState(() {
                    _endHour = DateTime(now.year, now.month, now.day,
                        timeOfDay.hour, timeOfDay.minute, 0, 0);

                    final diff = _endHour!.difference(_startHour!).inHours;
                    _hourSlots = [];
                    for (int i = 0; i < diff; i++) {
                      _hourSlots.add(false);
                    }
                  });
                }
              },
              child: Text('Change End Time'),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(timeFormatter.format(_startHour!)),
            Text(timeFormatter.format(_endHour!)),
          ],
        ),
        SizedBox(height: 20),
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(_hourSlots.length, (index) {
                final hour = _startHour!.add(Duration(hours: index));
                final endHour = _startHour!.add(Duration(hours: index + 1));
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                        "${timeFormatter.format(hour)} - ${timeFormatter.format(endHour)}"),
                    trailing: DropdownButton<bool>(
                      value: _hourSlots[index],
                      onChanged: (newValue) {
                        setState(() {
                          _hourSlots[index] = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Text('Yes'),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Text('No'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContent() {
    if (_isSubmitting) {
      return Center(
        child: ProgressDialog(message: "Saving profile..."),
      );
    } else {
      return Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          setState(() {
            if (_currentStep == 0 && _profileImage == null) {
              Fluttertoast.showToast(msg: 'Please set an image');
            } else if (_currentStep == 1 && _galleryImages.isEmpty) {
              Fluttertoast.showToast(msg: 'Please add at least one image');
            } else if (_currentStep < 2) {
              setState(() {
                _currentStep++;
              });
            } else {
              handleSubmit();
            }
          });
        },
        onStepTapped: (value) {
          setState(() {
            _currentStep = value;
          });
        },
        onStepCancel: () {
          setState(() {
            if (_currentStep > 0) {
              _currentStep--;
            }
          });
        },
        steps: [
          Step(
            title: Text('Profile Image'),
            content: _buildProfileImageStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text('Gallery'),
            content: _buildGalleryStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text('Time Slots'),
            content: _buildTimeSlotsStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Complete Profile'),
        ),
        body: _buildContent());
  }
}
