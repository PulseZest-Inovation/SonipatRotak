import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sonipat/data/imageSlider.dart';
import 'package:sonipat/logoutFxn.dart';
import 'package:sonipat/widgets/widgets.dart';

class DataList extends StatefulWidget {
  final String? userId;
  const DataList({Key? key, required this.userId}) : super(key: key);

  @override
  _DataListState createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  late List<Map<String, dynamic>> records;
  bool isAvailable = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    records = [];
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initializeData();
    });
  }

  Future<void> initializeData() async {
    await fetchData();
  }

  Future<void> updateData() async {
    records.clear();
    await fetchData();
  }

  void _deleteData(Map<String, dynamic> record) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text('Are you sure you want to delete this record?'),
          actions: [
            // Confirm button
            TextButton(
              onPressed: () async {
                try {
                  // Delete the citation document from Firestore
                  DocumentReference dataRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId);

                  await dataRef.collection('data').doc(record['id']).delete();

                  // Delete the associated file from Firebase Storage if present
                  if (record['photos'].isNotEmpty) {
                    for (int i = 0; i < record['photos'].length; i++)
                      await firebase_storage.FirebaseStorage.instance
                          .refFromURL(record['photos'][i])
                          .delete();
                  }
                  Toast.showToast('Deleted Successfully!');

                  // Remove the deleted citation from the records list
                  setState(() {
                    records.remove(record);
                    isAvailable = records.isNotEmpty;
                  });
                } catch (error) {
                  print('Error deleting citation: $error');
                  Toast.showToast('Failed to delete citation.');
                }
                Navigator.pop(context);
              },
              child: Text("Confirm", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget dataCard() {
    return ListView.separated(
        itemBuilder: (context, index) {
          List<String> imgs = [];
          for (int i = 0; i < records[index]['photos'].length; i++) {
            imgs.add(records[index]['photos'][i]);
          }
          return ExpansionTile(
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteData(records[index]);
              },
            ),
            title: Text(
              records[index]['name'],
              style: TextStyle(fontSize: 20),
            ),
            leading: Icon(Icons.line_weight_rounded),
            children: [
              if (records[index]['phone'] != '')
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
                        records[index]['phone'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10),
              if (records[index]['details'] != '')
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
                          records[index]['details'],
                          softWrap: true,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10),
              records[index]['photos'].isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GestureDetector(
                            child: Text(
                              'View Images',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ImageSlider(imageUrls: imgs)),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'No images available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: records.length);
  }

  Future<void> fetchData() async {
    try {
      DocumentReference dataRef;
      dataRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      QuerySnapshot querySnapshot = await dataRef.collection('data').get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isAvailable = true;
        });
        List<Map<String, dynamic>> fetchedRecords = [];
        querySnapshot.docs.forEach((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String documentId = document.id;

          // Add both document ID and data to the records list
          fetchedRecords.add({
            'id': documentId,
            ...data,
          });
        });
        setState(() {
          records = fetchedRecords;
        });
      } else {
        print('No matching documents found');
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      Toast.showToast('Something went wrong!');
      print('Error retrieving documents: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RO Data'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout_rounded),
          ),
        ],
        backgroundColor: Colors.red.shade100,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AddCitationPage(
          //       userId: widget.userId,
          //       caseId: widget.caseId,
          //       isCaseCitation: widget.isCaseCitation,
          //     ),
          //   ),
          // ).then((value) {
          //   if (value == true) {
          //     updateData();
          //   }
          // });
        },
        child: Icon(Icons.add_circle_rounded, size: 30),
        // backgroundColor: Colors.teal.shade100,
        // shape: CircleBorder(side: BorderSide(color: Colors.black, width: 1.5)),
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isAvailable
              ? dataCard()
              : Center(
                  child: Text(
                    'No Data Found!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black38),
                  ),
                ),
    );
  }
}
