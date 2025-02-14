import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExperiencePage extends StatefulWidget {
  @override
  _ExperiencePageState createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  void _saveExperience() async {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        return;
      }
      try {
        // Save experience data to Firestore
        await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .collection('experiences')
            .add({
          'startYear': _startYearController.text,
          'endYear': _endYearController.text,
          'position': _positionController.text,
          'organization': _organizationController.text,
          'city': _cityController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Experience saved successfully!")),
        );
        Navigator.pop(context); // Return to the previous screen
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(backgroundColor: Colors.deepOrange, title: Text("Add Experience")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _startYearController,
                decoration: InputDecoration(labelText: "Start Year", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter Start Year" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _endYearController,
                decoration: InputDecoration(labelText: "End Year", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter End Year" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: "Position", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter Position" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _organizationController,
                decoration: InputDecoration(labelText: "Organization", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter Organization" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter City" : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: _saveExperience,
                child: Text("Save Experience", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
