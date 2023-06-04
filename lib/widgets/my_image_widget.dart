import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyImageWidget extends StatelessWidget {
  final String imageUrl;
  final Function deleteImage;

  const MyImageWidget(
      {Key? key, required this.imageUrl, required this.deleteImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              deleteImage();
            },
          ),
        ),
      ],
    );
  }
}
