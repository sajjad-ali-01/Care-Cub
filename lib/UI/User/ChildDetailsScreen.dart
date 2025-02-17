import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNavigationBar.dart';

class BabyProfileScreen extends StatefulWidget {
  @override
  _BabyProfileScreenState createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  TextEditingController nameController = TextEditingController();

  DateTime? selectedDate;
  String selectedGender = "Boy";

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
  Future<void> setUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> saveBabyProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter child details')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('babyProfiles')
          .add({
        'name': nameController.text,
        'dateOfBirth': selectedDate,
        'gender': selectedGender,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setUserLoggedIn();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Tabs()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save baby profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF8C66),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Text("Baby Profile", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
              SizedBox(height: 5),
              Text("Personalize your experience", style: TextStyle(fontSize: 16, color: Colors.black54)),

              SizedBox(height: 30),
              Text("What’s your baby’s name?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text("Or nickname", style: TextStyle(color: Colors.black54)),

              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 25),
              Text("Choose child's Date of Birth", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 15),
              SizedBox(height: 10),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    selectedDate == null ? "Tap to select Date" : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),

              SizedBox(height: 25),
              Text("Select your baby’s gender", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ["Boy", "Girl", "Prefer not to say"].map((gender) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedGender = gender),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Chip(
                        label: Text(gender, style: TextStyle(color: selectedGender == gender ? Colors.white : Colors.black)),
                        backgroundColor: selectedGender == gender ? Colors.deepOrange.shade600 : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 130),
              ElevatedButton(
                onPressed: saveBabyProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Next →", style: TextStyle(color: Colors.purple.shade900, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}