import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewURL extends StatelessWidget {
  final String imageUrl;
  const ImageViewURL({Key? key, required this.imageUrl}) : super(key: key);

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
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
