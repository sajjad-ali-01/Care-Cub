import 'package:flutter/material.dart';
import 'award_page.dart';
import 'experience_page.dart';
import '../../Clinic.dart'; // Navigate to Add Clinic after completion

class AdvancedProfileInfoPage extends StatefulWidget {
  @override
  _AdvancedProfileInfoPageState createState() => _AdvancedProfileInfoPageState();
}

class _AdvancedProfileInfoPageState extends State<AdvancedProfileInfoPage> {
  List<String> awards = []; // ✅ List to store awards

  void _addAward(String award) {
    setState(() {
      awards.add(award);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Advanced Profile Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Awards & Recognitions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AwardPage()),
                );
                if (result != null) {
                  _addAward(result); // ✅ Add award to the list
                }
              },
              child: Text("Add Award", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),

            // ✅ Display list of added awards
            awards.isEmpty
                ? Text("No awards added yet.", style: TextStyle(color: Colors.grey))
                : Column(
              children: awards.map((award) => ListTile(
                title: Text(award),
                leading: Icon(Icons.star, color: Colors.amber),
              )).toList(),
            ),

            SizedBox(height: 20),
            Text("Experience", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExperiencePage()));
              },
              child: Text("Add Experience", style: TextStyle(color: Colors.white)),
            ),
            Spacer(),

            // ✅ "Complete Sign-In" button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddClinicScreen()));
                },
                child: Text("Complete Sign-In", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
