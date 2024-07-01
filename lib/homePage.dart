import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonipat/data/dataList.dart';
import 'data/allDataList.dart';
import 'logoutFxn.dart';

class HomePage extends StatefulWidget {
  final String? userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RO Data'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirmation"),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      // Confirm button
                      TextButton(
                        onPressed: () async {
                          logout(context);
                          Navigator.pop(context);
                        },
                        child: Text("Logout",
                            style: TextStyle(color: Colors.green)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:
                            Text("Cancel", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
        backgroundColor: Colors.red.shade100,
      ),
      body: Column(children: [
        SizedBox(height: 20),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(children: [
              Container(
                height: 60,
                // Set the background color of the TabBar
                child: const TabBar(
                  indicatorColor: Colors.blue,
                  indicatorWeight: 9.0, // Set the indicator color
                  tabs: [
                    Column(
                      children: [
                        Icon(
                          Icons.info,
                          size: 20,
                        ),
                        Text("My Data"),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 20,
                        ),
                        Text("All Data"),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    DataList(userId: widget.userId),
                    AllDataList(),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
