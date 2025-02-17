import 'package:flutter/material.dart';
import 'child_details_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> sessionTimings = [
    "10:00 - 11:00 AM",
    "11:00 - 12:00 PM",
    "12:00 - 01:00 PM",
    "01:00 - 02:00 PM",
    "02:00 - 03:00 PM",
  ];

  Map<String, List<Map<String, String>>> approvedSessions = {};

  @override
  void initState() {
    super.initState();
    loadApprovedAppointments();
  }

  Future<void> loadApprovedAppointments() async {
    Map<String, List<Map<String, String>>> fetchedData = await fetchApprovedAppointments();

    setState(() {
      approvedSessions = fetchedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
          title: Text("Dashboard",style: TextStyle(color: Colors.white)
            ,
          )),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: sessionTimings.length,
        itemBuilder: (context, index) {
          String session = sessionTimings[index];

          List<Color> tileColors = [
            Colors.yellow.shade100,
            Colors.green.shade100,
            Colors.orange.shade100,
            Colors.teal.shade100,
            Colors.purple.shade100,

          ];

          Color tileColor = tileColors[index % tileColors.length];

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            color: tileColor,
            child: ListTile(
              title: Text("Session: $session"),
              subtitle: Text("Tap to view accepted children"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showChildrenList(context, session);
              },
            ),
          );
        },
      ),
    );
  }

  void _showChildrenList(BuildContext context, String session) {
    List<Map<String, String>> children = approvedSessions[session] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Children in Session ($session)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              Expanded(
                child: children.isNotEmpty
                    ? ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {


                    Map<String, String> child = children[index];
                    return ListTile(
                      title: Text(child["name"] ?? ""),
                      subtitle: Text("Age: ${child["age"]} | Parent: ${child["parent"]}"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildDetailsPage(child: child),
                          ),
                        );
                      },
                    );
                  },
                )
                    : Center(child: Text("No approved children for this session")),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, List<Map<String, String>>>> fetchApprovedAppointments() async {

    await Future.delayed(Duration(seconds: 1));

    return {
      "10:00 - 11:00 AM": [
        {"name": "Ali Khan", "age": "4", "parent": "Mr. Khan"},
        {"name": "Sarah Ahmed", "age": "3", "parent": "Mrs. Ahmed"},
      ],
      "11:00 - 12:00 PM": [
        {"name": "Ayaan Malik", "age": "5", "parent": "Dr. Malik"},
      ],
    };
  }
}
