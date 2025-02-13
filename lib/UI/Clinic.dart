import 'package:flutter/material.dart';

class AddClinicScreen extends StatefulWidget {
  @override
  _AddClinicScreenState createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _timingsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Add Clinic"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Clinic Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              TextFormField(
                controller: _clinicNameController,
                decoration: InputDecoration(labelText: "Clinic/Hospital Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter address" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter city" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _timingsController,
                decoration: InputDecoration(labelText: "Timings", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter timings" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter location" : null,
              ),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Clinic Info Saved Successfully!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Save Clinic Info", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
