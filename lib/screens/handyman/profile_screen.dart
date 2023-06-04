import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/utils/helpers.dart';
import 'package:handyman_finder/widgets/handyman/handyman_drawer.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  bool _isUploading = false;
  bool _isSaving = false;

  File? _image;
  final ImagePicker picker = ImagePicker();

  final _firstNameController =
      TextEditingController(text: userModelCurrentInfo!.firstName);
  final _lastNameController =
      TextEditingController(text: userModelCurrentInfo!.lastName);
  final _businessNameController =
      TextEditingController(text: userModelCurrentInfo!.businessName);
  final _emailController =
      TextEditingController(text: userModelCurrentInfo!.email);
  final _phoneController =
      TextEditingController(text: userModelCurrentInfo!.phone);
  final _addressController =
      TextEditingController(text: userModelCurrentInfo!.address);
  String? selectedSkill = userModelCurrentInfo!.skill;
  String? selectedStatus = userModelCurrentInfo!.status;

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> uploadImage(File file) async {
    setState(() {
      _isUploading = true;
    });

    final ref = FirebaseStorage.instance
        .ref()
        .child(currentFirebaseUser!.uid)
        .child('displayPhotoUrl');

    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() async {
      setState(() {
        _isUploading = false;
      });
    });

    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  validateForm() {
    if (_firstNameController.text.length < 3 ||
        _lastNameController.text.length < 3 ||
        _businessNameController.text.length < 3) {
      Fluttertoast.showToast(msg: "Names must be at least 3 characters");
    } else if (selectedSkill == "") {
      Fluttertoast.showToast(msg: "Select a skill");
    } else if (_addressController.text.length < 3) {
      Fluttertoast.showToast(
          msg: "Physical address field must be at least 3 characters");
    } else if (!_emailController.text.contains('@')) {
      Fluttertoast.showToast(msg: "Email address invalid");
    } else if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number required");
    } else {
      saveChanges();
    }
  }

  saveChanges() async {
    setState(() {
      _isSaving = true;
    });
    Map<String, Object?> userMap = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "businessName": _businessNameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "skill": selectedSkill!.trim(),
      "displayPhotoUrl": userModelCurrentInfo!.displayPhotoUrl,
    };

    if (_image != null) {
      String? displayPhotoUrl = await uploadImage(_image!);
      userMap['displayPhotoUrl'] = displayPhotoUrl;
    }

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    usersRef.child(currentFirebaseUser!.uid).update(userMap);

    Fluttertoast.showToast(msg: "Changes saved!");

    HelperMethods.readCurrentOnlineUserInfo();

    setState(() {
      isEditing = false;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      drawer: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).colorScheme.primary),
        child: HandymanDrawer(
          email: userModelCurrentInfo!.email,
          firstName: userModelCurrentInfo!.firstName,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isEditing = !isEditing;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(isEditing ? Icons.remove_red_eye : Icons.edit),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isSaving
              ? ProgressDialog(message: 'Loading')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        isEditing
                            ? Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _getImage(),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: _image != null
                                          ? FileImage(_image!)
                                              as ImageProvider<Object>
                                          : NetworkImage(
                                              'https://via.placeholder.com/150'),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Change Image',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage: userModelCurrentInfo!
                                            .displayPhotoUrl !=
                                        ""
                                    ? NetworkImage(
                                        userModelCurrentInfo!.displayPhotoUrl!)
                                    : NetworkImage(
                                        'https://via.placeholder.com/150'),
                              ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isEditing)
                              Text(userModelCurrentInfo!.firstName ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            if (!isEditing)
                              Text(userModelCurrentInfo!.lastName ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            Text(
                              userModelCurrentInfo!.IDNo ?? '',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(thickness: 1),
                    SizedBox(height: 8),
                    if (isEditing)
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: 'First Name'),
                      ),
                    if (isEditing)
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(labelText: 'Last Name'),
                      ),
                    if (isEditing)
                      TextFormField(
                        controller: _businessNameController,
                        decoration: InputDecoration(labelText: 'Business Name'),
                      ),
                    if (!isEditing)
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Name',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            Text(
                              userModelCurrentInfo!.businessName ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 16),
                          ]),
                    if (isEditing)
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email',
                              style: TextStyle(fontStyle: FontStyle.italic)),
                          Text(userModelCurrentInfo!.email ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))
                        ],
                      ),
                    SizedBox(height: 16),
                    if (isEditing)
                      TextFormField(
                        controller: _phoneController,
                        decoration:
                            InputDecoration(labelText: 'Contact Number'),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contact Number',
                              style: TextStyle(fontStyle: FontStyle.italic)),
                          Text(userModelCurrentInfo!.phone ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))
                        ],
                      ),
                    SizedBox(height: 16),
                    if (isEditing)
                      TextFormField(
                        controller: _addressController,
                        decoration:
                            InputDecoration(labelText: 'Physical Address'),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Physical Address',
                              style: TextStyle(fontStyle: FontStyle.italic)),
                          Text(
                            userModelCurrentInfo!.address ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        ],
                      ),
                    SizedBox(height: 16),
                    if (isEditing)
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
                          ].map((user) {
                            return DropdownMenuItem(
                              child: Text(user,
                                  style: TextStyle(color: Colors.black)),
                              value: user,
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Specialization',
                              style: TextStyle(fontStyle: FontStyle.italic)),
                          Text(
                            userModelCurrentInfo!.skill ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    if (isEditing)
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Specialization / Skill',
                          border: UnderlineInputBorder(),
                        ),
                        child: DropdownButtonFormField(
                          iconSize: 25,
                          hint: Text('Change Status'),
                          onChanged: (newValue) {
                            setState(() {
                              selectedSkill = newValue.toString();
                            });
                          },
                          value: selectedStatus,
                          items: [
                            'Available',
                            'Unavailable',
                          ].map((user) {
                            return DropdownMenuItem(
                              child: Text(user,
                                  style: TextStyle(color: Colors.black)),
                              value: user,
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status',
                              style: TextStyle(fontStyle: FontStyle.italic)),
                          Text(
                            userModelCurrentInfo!.status ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    if (isEditing)
                      ElevatedButton(
                          onPressed: validateForm, child: Text('Save Changes'))
                  ],
                ),
        ),
      ),
    );
  }
}
