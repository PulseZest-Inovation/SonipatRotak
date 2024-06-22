import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart';
import 'package:sonipat/data/imageView.dart';

import '../widgets/fluttertoast.dart';

class AddData extends StatefulWidget {
  final String? userId;
  const AddData({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _images = [];

  bool isSavePressed = false;

  Future<void> _addData() async {
    setState(() {
      isSavePressed = true;
    });
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String details = _detailsController.text.trim();
    print('Name - $name');
    print('phone - $phone');
    print('details - $details');
    List<String> imageUrls = [];

    if (name.isEmpty && details.isEmpty && phone.isEmpty && _images == []) {
      Toast.showToast('No data is entered yet!');
      setState(() {
        isSavePressed = false;
      });
    } else {
      if (name.isEmpty) {
        Toast.showToast('RO Name Field cannot be empty!');
        setState(() {
          isSavePressed = false;
        });
      } else {
        try {
          DocumentReference dataRef;
          dataRef = FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('data')
              .doc();

          if (_images != []) {
            String timestamp = DateTime.now().toString();
            for (int i = 0; i < _images.length; i++) {
              String fileName = '$timestamp-$i';
              firebase_storage.UploadTask task = firebase_storage
                  .FirebaseStorage.instance
                  .ref('${widget.userId}/$fileName')
                  .putFile(_images[i]);

              // Get the URL of the uploaded image
              firebase_storage.TaskSnapshot snapshot = await task;
              String fileUrl = await snapshot.ref.getDownloadURL();
              imageUrls.add(fileUrl);
            }
          }
          await dataRef.set({
            'name': name,
            'phone': phone,
            'details': details,
            'photos': imageUrls,
          });
          setState(() {
            isSavePressed = false;
          });

          Toast.showToast('Data added successfully!');
          Navigator.pop(context, true);
        } catch (e) {
          // Handle errors
          setState(() {
            isSavePressed = false;
          });
          Toast.showToast('Something went wrong! Please try again later.');
          print("Error: $e");
        }
      }
    }
  }

  Future<void> _selectImage() async {
    final List<XFile>? images = await ImagePicker().pickMultiImage();
    if (images != null) {
      setState(() {
        _images.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  Future<void> uploadImage(String source) async {
    var status = await Permission.camera.request();
    final pickedFile;
    if (status.isGranted) {
      if (source == 'camera') {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      } else {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } else {
      Toast.showToast('Permission denied');
    }
  }

  Widget uploadCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Click Image from Camera'),
                    onTap: () async {
                      Navigator.pop(context);
                      uploadImage('camera');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Upload from Gallery'),
                    onTap: () async {
                      Navigator.pop(context);
                      _selectImage();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: ListTile(
          leading: Icon(Icons.upload),
          title: Text(
            'Upload Images',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Data'),
          backgroundColor: Colors.red.shade100,
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      label: Text("RO Name"),
                      hintText: "Enter RO name",
                      suffixIcon: Icon(Icons.credit_card),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter RO name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      label: Text("Phone Number"),
                      hintText: "Enter your phone number",
                      suffixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      label: Text("Details"),
                      hintText: "Enter details",
                      suffixIcon: Icon(Icons.details_rounded),
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter details';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  uploadCard(context),
                  SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: _images.map((image) {
                      return Stack(
                        children: [
                          GestureDetector(
                            child: Image.file(
                              image,
                              height: 150,
                              width: 150,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageView(
                                    image: image,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.remove(image);
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // if (_formKey.currentState!.validate()) {
                          //   // Perform login action
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(content: Text('Logging in...')),
                          //   );
                          // }
                          _addData();
                        },
                        child: isSavePressed
                            ? CircularProgressIndicator()
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
