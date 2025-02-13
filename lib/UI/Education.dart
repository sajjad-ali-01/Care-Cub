import 'package:flutter/material.dart';

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

              // Country (Fixed as Pakistan)
              TextFormField(
                controller: _countryController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Country", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),

              // City Field
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter your city" : null,
              ),
              SizedBox(height: 20),

              // Medical College Field
              TextFormField(
                controller: _collegeController,
                decoration: InputDecoration(labelText: "Medical College", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter your medical college" : null,
              ),
              SizedBox(height: 20),

              // Degree Field
              TextFormField(
                controller: _degreeController,
                decoration: InputDecoration(labelText: "Degree", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter your degree" : null,
              ),
              SizedBox(height: 20),

              // Graduation Year
              TextFormField(
                controller: _graduationYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Graduation Year", border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) return "Please enter graduation year";
                  if (int.tryParse(value) == null) return "Enter a valid year";
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Complete Sign-In Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Perform sign-in completion logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Sign-In Completed Successfully!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Complete Sign-In", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
