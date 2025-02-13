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

  void _saveExperience() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Experience Saved: ${_positionController.text} at ${_organizationController.text} (${_startYearController.text} - ${_endYearController.text}) in ${_cityController.text}")),
      );
      Navigator.pop(context);
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
