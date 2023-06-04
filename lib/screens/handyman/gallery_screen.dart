import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:handyman_finder/models/image_data_model.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/widgets/handyman/handyman_drawer.dart';
import 'package:handyman_finder/widgets/handyman/image_upload_button.dart';
import 'package:handyman_finder/widgets/my_image_widget.dart';
import 'package:path/path.dart';

class MyGallery extends StatefulWidget {
  @override
  State<MyGallery> createState() => _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> {
  GlobalKey<ScaffoldState> hmGKey = GlobalKey<ScaffoldState>();

  bool openNavigationDrawer = true;

  bool _loadingImages = true;

  List<ImageDataModel> _imageUrlList = [];

  Future<void> loadImages() async {
    setState(() {
      _loadingImages = true;
      _imageUrlList = [];
    });

    final ref = FirebaseStorage.instance
        .ref()
        .child(currentFirebaseUser!.uid)
        .child('gallery');

    final result = await ref.listAll();

    for (final item in result.items) {
      final url = await item.getDownloadURL();
      final path = item.fullPath;
      _imageUrlList.add(ImageDataModel(url: url, path: path));
    }

    setState(() {
      _loadingImages = false;
    });
  }

  @override
  void initState() {
    loadImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isUploading = false;

    Future<String?> uploadImage(File file) async {
      setState(() {
        _loadingImages = true;
      });

      final fileName = basename(file.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child(currentFirebaseUser!.uid)
          .child('gallery')
          .child(fileName);

      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() async {
        await loadImages();

        setState(() {
          _isUploading = false;
        });
        Fluttertoast.showToast(msg: 'Image upload successful!');
      });

      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    }

    Future<String> deleteImage(String imagePath) async {
      setState(() {
        _loadingImages = true;
        _imageUrlList = [];
      });

      await FirebaseStorage.instance.ref(imagePath).delete();
      setState(() {
        loadImages();
        Fluttertoast.showToast(msg: 'Image deleted successfully!');
      });

      return 'Image deleted successfully';
    }

    return Scaffold(
      drawer: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).colorScheme.primary),
        child: HandymanDrawer(
          firstName: userModelCurrentInfo!.firstName,
          email: userModelCurrentInfo!.email,
        ),
      ),
      appBar: AppBar(
          title: Text('My Gallery (${_imageUrlList.length})',
              style: TextStyle(fontStyle: FontStyle.normal))),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  // Loading
                  SizedBox(height: 20),
                  if (_loadingImages)
                    ProgressDialog(
                      message: 'Loading...',
                    ),

                  // Image grid
                  if (_imageUrlList.length == 0 &&
                      !_isUploading &&
                      !_loadingImages)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No images uploaded yet!',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ),
                    ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      itemCount: _imageUrlList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: MyImageWidget(
                            imageUrl: _imageUrlList[index].url,
                            deleteImage: () =>
                                deleteImage(_imageUrlList[index].path),
                          ),
                        );
                      },
                    ),
                  ),

                  // // Alert dialog
                  // if (_isUploading)
                  //   ProgressDialog(
                  //     message: 'Uploading...',
                  //   ),

                  // Upload button
                  if (!_loadingImages &&
                      !_isUploading &&
                      _imageUrlList.length < 5)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MyUploadButton(onUpload: uploadImage),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
