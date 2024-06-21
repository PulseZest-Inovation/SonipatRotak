import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  ImageSlider({super.key, required this.imageUrls});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;
  CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider(
            items: widget.imageUrls.map((url) {
              return Container(
                child: Image.network(url),
              );
            }).toList(),
            options: CarouselOptions(
              enlargeCenterPage: true,
              height: 200,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            carouselController: _carouselController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.imageUrls.length > 1 && _currentIndex > 0)
                ElevatedButton(
                  child: Text('Prev'),
                  onPressed: () {
                    _carouselController.previousPage();
                  },
                ),
              if (widget.imageUrls.length > 1 &&
                  _currentIndex < widget.imageUrls.length - 1)
                ElevatedButton(
                  child: Text('Next'),
                  onPressed: () {
                    _carouselController.nextPage();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
