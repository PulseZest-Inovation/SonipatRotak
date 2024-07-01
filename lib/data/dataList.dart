import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sonipat/widgets/widgets.dart';
import 'addData.dart';
import 'dataDetails.dart';

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
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Divider(),
                      Text(
                        'Deleting...',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please wait!',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                );
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
                  Navigator.pop(context);
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DataDetails(data: records[index])),
              );
            },
            child: ListTile(
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
              leading: Icon(Icons.data_saver_off_rounded),
            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddData(
                userId: widget.userId,
              ),
            ),
          ).then((value) {
            if (value == true) {
              updateData();
            }
          });
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
