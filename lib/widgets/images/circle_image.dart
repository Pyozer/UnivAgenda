import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {
  final Image image;

  const CircleImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      shape: const CircleBorder(),
      child: ClipOval(child: image, clipBehavior: Clip.antiAlias),
    );
  }
}
