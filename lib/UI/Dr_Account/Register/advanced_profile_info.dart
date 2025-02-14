import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'award_page.dart';
import 'experience_page.dart';
import 'Clinic.dart'; // Navigate to Add Clinic after completion

class AdvancedProfileInfoPage extends StatefulWidget {
  @override
  _AdvancedProfileInfoPageState createState() => _AdvancedProfileInfoPageState();
}

class _AdvancedProfileInfoPageState extends State<AdvancedProfileInfoPage> {
  // Function to fetch awards as a stream
  Stream<List<String>> _fetchAwardsStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]); // Return an empty stream if user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('Doctors')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final List<dynamic> awardsList = snapshot['awards'] ?? [];
        return awardsList.cast<String>();
      } else {
        return [];
      }
    });
  }

  Stream<QuerySnapshot> _fetchExperiencesStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty(); // Return an empty stream if user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('Doctors')
        .doc(user.uid)
        .collection('experiences')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Advanced Profile Info"),
      ),
      body: SingleChildScrollView(
        // Wrap the entire body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Awards & Recognitions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // Button to add a new award
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AwardPage()),
                  );
                  if (result != null) {
                    // No need to manually add the award here, as the StreamBuilder will update automatically
                  }
                },
                child: Text("Add Award", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),

              // Display list of added awards using StreamBuilder
              StreamBuilder<List<String>>(
                stream: _fetchAwardsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Error fetching awards: ${snapshot.error}");
                  }

                  final List<String> awards = snapshot.data ?? [];

                  return awards.isEmpty
                      ? Text("No awards added yet.", style: TextStyle(color: Colors.grey))
                      : Column(
                    children: awards.map((award) => ListTile(
                      title: Text(award),
                      leading: Icon(Icons.star, color: Colors.amber),
                    )).toList(),
                  );
                },
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
              SizedBox(height: 10),

              // Display list of added experiences using StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: _fetchExperiencesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Error fetching experiences: ${snapshot.error}");
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("No experiences added yet.", style: TextStyle(color: Colors.grey));
                  }

                  return Container(
                    height: 200, // Set a fixed height or use Expanded/Flexible
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(), // Prevent nested scrolling
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final experience = snapshot.data!.docs[index];
                        return ListTile(
                          title: Text(experience['position']),
                          subtitle: Text(
                            "${experience['organization']}, ${experience['city']}\n"
                                "${experience['startYear']} - ${experience['endYear']}",
                          ),
                          leading: Icon(Icons.work, color: Colors.blue),
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              // "Complete Sign-In" button
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
      ),
    );
  }
}