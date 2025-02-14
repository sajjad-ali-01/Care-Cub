import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AwardPage extends StatefulWidget {
  @override
  _AwardPageState createState() => _AwardPageState();
}

class _AwardPageState extends State<AwardPage> {
  final _formKey = GlobalKey<FormState>();
  String awardName = '';
  String year = '';

  // Function to save the award to Firestore
  void _saveAward() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Reference to the user's document in Firestore
      final userDoc = FirebaseFirestore.instance.collection('Doctors').doc(user.uid);

      // Add the new award to the list
      try {
        await userDoc.update({
          'awards': FieldValue.arrayUnion(["$awardName ($year)"]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Award added successfully')),
        );

        // Navigate back to the previous screen
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add award: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Award"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Award Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter Award Name" : null,
                onSaved: (value) => awardName = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter Year" : null,
                onSaved: (value) => year = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: _saveAward,
                child: Text(
                  "Save Award",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}