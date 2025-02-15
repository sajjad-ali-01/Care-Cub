import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Home.dart';

class AddClinicScreen extends StatefulWidget {
  @override
  _AddClinicScreenState createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _FeeController = TextEditingController();
  bool _isLoading = false;

  // TimeOfDay _openingTime = TimeOfDay(hour: 9, minute: 0);
  // TimeOfDay _closingTime = TimeOfDay(hour: 17, minute: 0);

  // List of days for availability
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Track selected days and their timings
  final Map<String, Map<String, dynamic>> _selectedDays = {
    'Monday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Tuesday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Wednesday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Thursday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Friday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Saturday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Sunday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
  };

  Future<void> _selectTime(BuildContext context, String day, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedDays[day]!['start']! : _selectedDays[day]!['end']!,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedDays[day]!['start'] = picked;
        } else {
          _selectedDays[day]!['end'] = picked;
        }
      });
    }
  }

  // Toggle day selection
  void _toggleDaySelection(String day) {
    setState(() {
      _selectedDays[day]!['isSelected'] = !_selectedDays[day]!['isSelected']!;
    });
  }

  void _saveClinicInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        setState(() {
          _isLoading = false; // Stop loading
        });
        return;
      }

      try {
        // Get the selected days and their timings
        final Map<String, Map<String, String>> availability = {};
        _selectedDays.forEach((day, timings) {
          if (timings['isSelected']!) {
            availability[day] = {
              'start': timings['start']!.format(context),
              'end': timings['end']!.format(context),
            };
          }
        });

        await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .collection('clinics')
            .add({
          'ClinicName': _clinicNameController.text,
          'ClinicCity': _cityController.text,
          'Address': _addressController.text,
          'Location': _locationController.text,
          'Availability': availability,
          'Fees': _FeeController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clinic Info Saved Successfully!")),
        );

        // Clear the form
        _clinicNameController.clear();
        _cityController.clear();
        _addressController.clear();
        _locationController.clear();
        setState(() {
          _selectedDays.forEach((key, value) {
            value['isSelected'] = false; // Reset selected days
          });
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save clinic: ${e.toString()}")),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Add Clinic/Hospital", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add one or more Clinics/Hospitals where you can be available",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _clinicNameController,
                decoration: InputDecoration(labelText: "Clinic/Hospital Name",hintText: "Ali Hospital", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _FeeController,
                decoration: InputDecoration(labelText: "Fees",hintText: "1000", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address",hintText: "123,street 2,Ali town" ,border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter address" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City",hintText: "Lahore", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter city" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter location" : null,
              ),
              SizedBox(height: 20),

              Text(
                "Select Availability Days and Timings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Display days of the week with checkboxes and time pickers
              Column(
                children: _daysOfWeek.map((day) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(day),
                        value: _selectedDays[day]!['isSelected'],
                        onChanged: (value) {
                          _toggleDaySelection(day);
                        },
                      ),
                      if (_selectedDays[day]!['isSelected']!)
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Start Time"),
                                subtitle: Text(_selectedDays[day]!['start']!.format(context)),
                                trailing: Icon(Icons.access_time),
                                onTap: () => _selectTime(context, day, true),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text("End Time"),
                                subtitle: Text(_selectedDays[day]!['end']!.format(context)),
                                trailing: Icon(Icons.access_time),
                                onTap: () => _selectTime(context, day, false),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _saveClinicInfo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Save Clinic Info", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveClinicInfo();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Save and Finish", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}