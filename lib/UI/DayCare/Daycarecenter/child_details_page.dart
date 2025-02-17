import 'package:flutter/material.dart';
import 'report_page.dart';

class ChildDetailsPage extends StatelessWidget {
  final Map<String, String> child;

  ChildDetailsPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Child Details",
            style: TextStyle(color: Colors.white),
          ),
        backgroundColor: Colors.deepOrange.shade400,
      ),
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
                      childAge: child["age"]!,
                      parentName: child["parent"]!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Fill Report",style: TextStyle(fontSize: 15,color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
