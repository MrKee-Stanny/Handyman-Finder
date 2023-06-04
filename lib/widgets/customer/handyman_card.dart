import 'package:flutter/material.dart';
import 'package:handyman_finder/widgets/customer/handyman_profile.dart';

class HandymanCard extends StatelessWidget {
  final Map<dynamic, dynamic> handyman;
  const HandymanCard({Key? key, required this.handyman}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => HandymanProfile(handyman)));
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.black),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: handyman['displayPhotoUrl'] != "" &&
                              handyman['displayPhotoUrl'] != null
                          ? NetworkImage(handyman['displayPhotoUrl'])
                          : handyman['galleryImageUrls'] != null &&
                                  handyman['galleryImageUrls'][0] != null
                              ? NetworkImage(handyman['galleryImageUrls'][0])
                              : AssetImage('assets/images/dark-logo.png')
                                  as ImageProvider<Object>,
                      fit: BoxFit.cover)),
            ),
            Container(
              color: Colors.white.withOpacity(0.6),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(handyman['businessName'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(handyman['skill'], style: TextStyle(fontSize: 16)),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
