import 'dart:io';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final File image;
  const ImageView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
        backgroundColor: Colors.red.shade100,
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.file(image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
