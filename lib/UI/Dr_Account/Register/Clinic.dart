import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ThankyouScreen.dart';

class AddClinicScreen extends StatefulWidget {
  @override
  _AddClinicScreenState createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController FeeController = TextEditingController();
  bool isLoading = false;


  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, Map<String, dynamic>> selectedDays = {
    'Monday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Tuesday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Wednesday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Thursday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Friday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Saturday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Sunday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
  };

  Future<void> selectTime(BuildContext context, String day, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? selectedDays[day]!['start']! : selectedDays[day]!['end']!,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          selectedDays[day]!['start'] = picked;
        } else {
          selectedDays[day]!['end'] = picked;
        }
      });
    }
  }

  void toggleDaySelection(String day) {
    setState(() {
      selectedDays[day]!['isSelected'] = !selectedDays[day]!['isSelected']!;
    });
  }

  void saveClinicInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      try {
        final Map<String, Map<String, String>> availability = {};
        selectedDays.forEach((day, timings) {
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
          'ClinicName': clinicNameController.text,
          'ClinicCity': cityController.text,
          'Address': addressController.text,
          'Location': locationController.text,
          'Availability': availability,
          'Fees': FeeController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clinic Info Saved Successfully!")),
        );

        clinicNameController.clear();
        cityController.clear();
        addressController.clear();
        locationController.clear();
        setState(() {
          selectedDays.forEach((key, value) {
            value['isSelected'] = false;
          });
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save clinic: ${e.toString()}")),
        );
      } finally {
        setState(() {
          isLoading = false;
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
                controller: clinicNameController,
                decoration: InputDecoration(labelText: "Clinic/Hospital Name",hintText: "Ali Hospital", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: FeeController,
                decoration: InputDecoration(labelText: "Fees",hintText: "1000", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Address",hintText: "123,street 2,Ali town" ,border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter address" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: "City",hintText: "Lahore", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter city" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter location" : null,
              ),
              SizedBox(height: 20),

              Text(
                "Select Availability Days and Timings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              Column(
                children: daysOfWeek.map((day) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(day),
                        value: selectedDays[day]!['isSelected'],
                        onChanged: (value) {
                          toggleDaySelection(day);
                        },
                      ),
                      if (selectedDays[day]!['isSelected']!)
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Start Time"),
                                subtitle: Text(selectedDays[day]!['start']!.format(context)),
                                trailing: Icon(Icons.access_time),
                                onTap: () => selectTime(context, day, true),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text("End Time"),
                                subtitle: Text(selectedDays[day]!['end']!.format(context)),
                                trailing: Icon(Icons.access_time),
                                onTap: () => selectTime(context, day, false),
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
                  onPressed: saveClinicInfo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Save Clinic Info", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveClinicInfo();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ThankYouScreen()));
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