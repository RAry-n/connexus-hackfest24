import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserPhoto extends StatelessWidget {
  UserPhoto({super.key, required this.radius, required this.url});

  double radius;
  String url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context , imageProvider){
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
            ),
          );
        },
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
