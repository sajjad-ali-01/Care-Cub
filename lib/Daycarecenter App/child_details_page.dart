import 'package:flutter/material.dart';
import 'report_page.dart';

class ChildDetailsPage extends StatelessWidget {
  final Map<String, String> child;

  ChildDetailsPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Child Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${child["name"]}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Age: ${child["age"]}", style: TextStyle(fontSize: 18)),
            Text("Parent: ${child["parent"]}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPage(
                      childName: child["name"]!,
                      childAge: child["age"]!,     // ✅ Pass child age
                      parentName: child["parent"]!, // ✅ Pass parent name
                    ),
                  ),
                );
              },
              child: Text("Fill Report"),
            ),
          ],
        ),
      ),
    );
  }
}
