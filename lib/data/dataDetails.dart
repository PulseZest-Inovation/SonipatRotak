import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../logoutFxn.dart';
import 'imageFromURL.dart';

class DataDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const DataDetails({Key? key, required this.data}) : super(key: key);

  @override
  _DataDetailsState createState() => _DataDetailsState();
}

class _DataDetailsState extends State<DataDetails> {
  List<String> imgs = [];
  int _currentIndex = 0;
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  void fetchPhotos() {
    for (int i = 0; i < widget.data['photos'].length; i++) {
      imgs.add(widget.data['photos'][i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        backgroundColor: Colors.red.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              if (widget.data['phone'] != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 22,
                      ),
                      SizedBox(width: 20),
                      Text(
                        widget.data['phone'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10),
              if (widget.data['details'] != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.details,
                        size: 22,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          widget.data['details'],
                          softWrap: true,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 30),
              if (widget.data['photos'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Images :-',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              widget.data['photos'].isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CarouselSlider(
                          items: imgs.map((url) {
                            return GestureDetector(
                              child: Container(
                                child: Image.network(url),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewURL(
                                      imageUrl: url,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            height: MediaQuery.of(context).size.height * 0.5,
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
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (imgs.length > 1 && _currentIndex > 0)
                              ElevatedButton(
                                child: Text('Prev'),
                                onPressed: () {
                                  _carouselController.previousPage();
                                },
                              ),
                            if (imgs.length > 1 &&
                                _currentIndex < imgs.length - 1)
                              ElevatedButton(
                                child: Text('Next'),
                                onPressed: () {
                                  _carouselController.nextPage();
                                },
                              ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'No images available',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
