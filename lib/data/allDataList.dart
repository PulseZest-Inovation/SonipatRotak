import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sonipat/data/dataDetails.dart';
import 'package:sonipat/widgets/widgets.dart';

class AllDataList extends StatefulWidget {
  const AllDataList({Key? key}) : super(key: key);

  @override
  _AllDataListState createState() => _AllDataListState();
}

class _AllDataListState extends State<AllDataList> {
  late Map<Map<String, String>, List<Map<String, dynamic>>> records;
  bool isAvailable = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    records = {};
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

  Widget dataCard() {
    List<Widget> list = [];

    records.forEach((user, records) {
      list.add(ListTile(
        title: Text(
          user['name']!,
          style: TextStyle(fontSize: 20),
        ),
        subtitle: Text(
          user['email']!,
          style: TextStyle(fontSize: 16),
        ),
        leading: Icon(Icons.person),
      ));

      for (int i = 0; i < records.length; i++) {
        list.add(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DataDetails(data: records[i])),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              title: Text('${i + 1}. ${records[i]['name']}'),
            ),
          ),
        ));
      }

      list.add(Divider());
    });

    return ListView(
      children: list,
    );
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isAvailable = true;
        });
        Map<Map<String, String>, List<Map<String, dynamic>>> allRecords = {};

        await Future.forEach(querySnapshot.docs, (document) async {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          String userId = document.id;
          String userName = userData['username'];
          String userEmail = userData['email'];

          QuerySnapshot dataQuerySnapshot =
              await document.reference.collection('data').get();

          if (dataQuerySnapshot.docs.isNotEmpty) {
            List<Map<String, dynamic>> userRecords = [];
            dataQuerySnapshot.docs.forEach((dataDocument) {
              Map<String, dynamic> data =
                  dataDocument.data() as Map<String, dynamic>;
              String documentId = dataDocument.id;

              // Add both document ID and data to the records list
              userRecords.add({
                'id': documentId,
                ...data,
              });
            });

            // Only add user to allRecords if they have data
            allRecords[{'id': userId, 'name': userName, 'email': userEmail}] =
                userRecords;
          }
        });

        setState(() {
          records = allRecords;
        });
      } else {
        print('No data found');
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
