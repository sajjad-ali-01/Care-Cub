import 'package:flutter/material.dart';
import 'advanced_profile_info.dart'; // Import the Advanced Profile Info screen

class EducationScreen extends StatefulWidget {
  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countryController = TextEditingController(text: "Pakistan");
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();

  void _saveEducation() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Education Details Saved Successfully!")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdvancedProfileInfoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Education Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Education Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              TextFormField(
                controller: _countryController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Country", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter your city" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _collegeController,
                decoration: InputDecoration(labelText: "College/University", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter your college/university" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _degreeController,
                decoration: InputDecoration(labelText: "Degree", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter your degree" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _graduationYearController,
                decoration: InputDecoration(labelText: "Graduation Year", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter your graduation year" : null,
              ),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: _saveEducation,
                  child: Text("Next", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
