import 'package:flutter/material.dart';

class PatientHistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  PatientHistoryPage(this.history);

  @override
  _PatientHistoryPageState createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredHistory = widget.history
        .where((appointment) =>
        appointment['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Search by Patient Name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHistory.length,
              itemBuilder: (context, index) {
                final appointment = filteredHistory[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/profile_pic.png"),
                    ),
                    title: Text(appointment['name']),
                    subtitle: Text("Time: ${appointment['time']}"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailPage(appointment),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  PatientDetailPage(this.appointment);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/images/profile_pic.png"),
              ),
            ),
            SizedBox(height: 16),
            Text(appointment['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Gender: ${appointment['gender']}"),
            Text("Age: ${appointment['age']}"),
            Text("Contact: ${appointment['contact']}"),
            Text("Time: ${appointment['time']}"),
            SizedBox(height: 10),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(appointment['description']),
          ],
        ),
      ),
    );
  }
}
